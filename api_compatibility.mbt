///|
pub(all) enum ApiChangeKind {
  Added
  Removed
  Changed
} derive(Debug, Eq)

///|
pub(all) struct ApiChange {
  kind : ApiChangeKind
  identity : String
  before : String
  after : String
} derive(Debug, Eq)

///|
pub fn ApiChange::kind_name(self : ApiChange) -> String {
  match self.kind {
    Added => "added"
    Removed => "removed"
    Changed => "changed"
  }
}

///|
pub fn ApiChange::summary(self : ApiChange) -> String {
  self.kind_name() + " " + self.identity
}

///|
pub(all) struct ApiCompatibility {
  before_count : Int
  after_count : Int
  added : Array[String]
  removed : Array[String]
  changed : Array[ApiChange]
  required_bump : VersionBump
} derive(Debug, Eq)

///|
pub fn analyze_api_compatibility(
  before : String,
  after : String,
) -> ApiCompatibility {
  let before_declarations = api_public_declarations(before)
  let after_declarations = api_public_declarations(after)
  let added : Array[String] = []
  let removed : Array[String] = []
  let changed : Array[ApiChange] = []
  let mut index = 0
  while index < after_declarations.length() {
    let declaration = after_declarations[index]
    let identity = api_declaration_identity(declaration)
    match api_find_declaration(before_declarations, identity) {
      None => added.push(declaration)
      Some(before_index) => {
        let previous = before_declarations[before_index]
        if previous != declaration {
          changed.push(ApiChange::{
            kind: Changed,
            identity,
            before: previous,
            after: declaration,
          })
        }
      }
    }
    index += 1
  }
  index = 0
  while index < before_declarations.length() {
    let declaration = before_declarations[index]
    let identity = api_declaration_identity(declaration)
    match api_find_declaration(after_declarations, identity) {
      None => removed.push(declaration)
      Some(_) => ()
    }
    index += 1
  }
  let required_bump = if removed.length() > 0 || changed.length() > 0 {
    Major
  } else if added.length() > 0 {
    Minor
  } else {
    SameVersion
  }
  ApiCompatibility::{
    before_count: before_declarations.length(),
    after_count: after_declarations.length(),
    added,
    removed,
    changed,
    required_bump,
  }
}

///|
pub fn ApiCompatibility::is_compatible(self : ApiCompatibility) -> Bool {
  self.removed.length() == 0 && self.changed.length() == 0
}

///|
pub fn ApiCompatibility::has_changes(self : ApiCompatibility) -> Bool {
  self.added.length() > 0 ||
  self.removed.length() > 0 ||
  self.changed.length() > 0
}

///|
pub fn ApiCompatibility::summary(self : ApiCompatibility) -> String {
  "api-compatible=" +
  bool_text(self.is_compatible()) +
  ", before=" +
  self.before_count.to_string() +
  ", after=" +
  self.after_count.to_string() +
  ", added=" +
  self.added.length().to_string() +
  ", removed=" +
  self.removed.length().to_string() +
  ", changed=" +
  self.changed.length().to_string() +
  ", required-bump=" +
  version_bump_name(self.required_bump)
}

///|
pub fn ApiCompatibility::to_markdown(self : ApiCompatibility) -> String {
  let mut out = "## API Compatibility\n\n"
  out = out + "- Compatible: " + bool_text(self.is_compatible()) + "\n"
  out = out + "- Before declarations: " + self.before_count.to_string() + "\n"
  out = out + "- After declarations: " + self.after_count.to_string() + "\n"
  out = out +
    "- Required SemVer bump: " +
    version_bump_name(self.required_bump) +
    "\n"
  out = out + "- Added declarations: " + self.added.length().to_string() + "\n"
  out = out +
    "- Removed declarations: " +
    self.removed.length().to_string() +
    "\n"
  out = out +
    "- Changed declarations: " +
    self.changed.length().to_string() +
    "\n"
  let with_added = api_changes_section(out, "Added", self.added)
  let with_removed = api_changes_section(with_added, "Removed", self.removed)
  api_changed_section(with_removed, self.changed)
}

///|
pub(all) struct ApiReleaseContract {
  compatibility : ApiCompatibility
  migration : ApiMigrationPlan
  before_version : String
  after_version : String
  required_bump : VersionBump
  declared_bump : VersionBump
  passes : Bool
} derive(Debug, Eq)

///|
pub fn build_api_release_contract(
  before_snapshot : String,
  after_snapshot : String,
  before_version : String,
  after_version : String,
) -> ApiReleaseContract {
  let compatibility = analyze_api_compatibility(before_snapshot, after_snapshot)
  let migration = build_api_migration_plan(compatibility)
  let declared_bump = classify_version_bump(before_version, after_version)
  let required_bump = compatibility.required_bump
  ApiReleaseContract::{
    compatibility,
    migration,
    before_version,
    after_version,
    required_bump,
    declared_bump,
    passes: api_release_contract_passes(required_bump, declared_bump),
  }
}

///|
pub fn ApiReleaseContract::is_compatible(self : ApiReleaseContract) -> Bool {
  self.compatibility.is_compatible()
}

///|
pub fn ApiReleaseContract::passes(self : ApiReleaseContract) -> Bool {
  self.passes
}

///|
pub fn ApiReleaseContract::summary(self : ApiReleaseContract) -> String {
  "release-contract=" +
  bool_text(self.passes) +
  ", api-compatible=" +
  bool_text(self.is_compatible()) +
  ", declared-bump=" +
  version_bump_name(self.declared_bump) +
  ", required-bump=" +
  version_bump_name(self.required_bump) +
  ", changes=" +
  self.compatibility.added.length().to_string() +
  "/" +
  self.compatibility.removed.length().to_string() +
  "/" +
  self.compatibility.changed.length().to_string() +
  ", migration-required=" +
  bool_text(self.migration.migration_required)
}

///|
pub fn ApiReleaseContract::to_markdown(self : ApiReleaseContract) -> String {
  let mut out = "# API Release Contract\n\n"
  out = out + "- Before version: `" + self.before_version + "`\n"
  out = out + "- After version: `" + self.after_version + "`\n"
  out = out +
    "- Required bump: `" +
    version_bump_name(self.required_bump) +
    "`\n"
  out = out +
    "- Declared bump: `" +
    version_bump_name(self.declared_bump) +
    "`\n"
  out = out + "- Contract passes: " + bool_text(self.passes) + "\n\n"
  out = out + self.migration.to_markdown() + "\n"
  out + self.compatibility.to_markdown()
}

///|
pub fn ApiReleaseContract::to_json(self : ApiReleaseContract) -> String {
  let mut out = "{"
  out = out + "\"before_version\":\"" + json_escape(self.before_version) + "\","
  out = out + "\"after_version\":\"" + json_escape(self.after_version) + "\","
  out = out +
    "\"required_bump\":\"" +
    version_bump_name(self.required_bump) +
    "\","
  out = out +
    "\"declared_bump\":\"" +
    version_bump_name(self.declared_bump) +
    "\","
  out = out + "\"passes\":" + api_json_bool(self.passes) + ","
  out = out + "\"added\":" + self.compatibility.added.length().to_string() + ","
  out = out +
    "\"removed\":" +
    self.compatibility.removed.length().to_string() +
    ","
  out = out +
    "\"changed\":" +
    self.compatibility.changed.length().to_string() +
    ","
  out = out + "\"breaking\":" + self.migration.breaking_count.to_string() + ","
  out = out +
    "\"migration_required\":" +
    api_json_bool(self.migration.migration_required)
  out + "}"
}

///|
fn api_json_bool(value : Bool) -> String {
  if value {
    "true"
  } else {
    "false"
  }
}

///|
pub fn api_snapshot_declarations(snapshot : String) -> Array[String] {
  api_public_declarations(snapshot)
}

///|
fn api_release_contract_passes(
  required : VersionBump,
  declared : VersionBump,
) -> Bool {
  let required_rank = api_bump_rank(required)
  let declared_rank = api_bump_rank(declared)
  declared_rank >= 0 && declared_rank >= required_rank
}

///|
fn api_bump_rank(bump : VersionBump) -> Int {
  match bump {
    Major => 3
    Minor => 2
    Patch => 1
    SameVersion => 0
    InvalidVersion => -1
  }
}

///|
fn api_changes_section(
  current : String,
  title : String,
  changes : Array[String],
) -> String {
  if changes.length() == 0 {
    current
  } else {
    let mut out = current + "\n### " + title + "\n\n"
    let mut index = 0
    while index < changes.length() {
      out = out + "- `" + changes[index] + "`\n"
      index += 1
    }
    out
  }
}

///|
fn api_changed_section(current : String, changes : Array[ApiChange]) -> String {
  if changes.length() == 0 {
    current
  } else {
    let mut out = current + "\n### Changed\n\n"
    let mut index = 0
    while index < changes.length() {
      let change = changes[index]
      out = out + "- `" + change.identity + "`\n"
      out = out + "  - before: `" + change.before + "`\n"
      out = out + "  - after: `" + change.after + "`\n"
      index += 1
    }
    out
  }
}

///|
fn api_public_declarations(snapshot : String) -> Array[String] {
  let declarations : Array[String] = []
  let lines = split_lines(snapshot)
  let mut current = ""
  let mut in_block = false
  let mut index = 0
  while index < lines.length() {
    let line = trim_ascii(lines[index])
    if line.length() > 0 {
      if in_block {
        current = current + "\n" + line
        if contains(line, "}") {
          declarations.push(current)
          current = ""
          in_block = false
        }
      } else if starts_with(line, "pub ") || starts_with(line, "pub(") {
        if contains(line, "{") && !contains(line, "}") {
          current = line
          in_block = true
        } else {
          declarations.push(line)
        }
      }
    }
    index += 1
  }
  if current.length() > 0 {
    declarations.push(current)
  }
  declarations
}

///|
fn api_declaration_identity(declaration : String) -> String {
  let lines = split_lines(declaration)
  if lines.length() == 0 {
    return ""
  }
  let first = lines[0]
  let body = if starts_with(first, "pub(all)") {
    trim_ascii(slice(first, 8, first.length()))
  } else if starts_with(first, "pub ") {
    trim_ascii(slice(first, 4, first.length()))
  } else {
    first
  }
  let kind = first_token(body)
  let rest = if body.length() > kind.length() {
    trim_ascii(slice(body, kind.length(), body.length()))
  } else {
    ""
  }
  let name = if kind == "fn" {
    match index_of(rest, "(") {
      Some(open) => trim_ascii(slice(rest, 0, open))
      None => first_token(rest)
    }
  } else {
    first_token(rest)
  }
  kind + ":" + name
}

///|
fn api_find_declaration(items : Array[String], identity : String) -> Int? {
  let mut index = 0
  while index < items.length() {
    if api_declaration_identity(items[index]) == identity {
      return Some(index)
    }
    index += 1
  }
  None
}
