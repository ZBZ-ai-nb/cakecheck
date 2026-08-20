///|
pub(all) struct ApiCompatibility {
  before_count : Int
  after_count : Int
  added : Array[String]
  removed : Array[String]
  required_bump : VersionBump
} derive(Debug, Eq)

///|
pub fn analyze_api_compatibility(
  before : String,
  after : String,
) -> ApiCompatibility {
  let before_declarations = api_public_declarations(before)
  let after_declarations = api_public_declarations(after)
  let added = api_difference(after_declarations, before_declarations)
  let removed = api_difference(before_declarations, after_declarations)
  let required_bump = if removed.length() > 0 {
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
    required_bump,
  }
}

///|
pub fn ApiCompatibility::is_compatible(self : ApiCompatibility) -> Bool {
  self.removed.length() == 0
}

///|
pub fn ApiCompatibility::has_changes(self : ApiCompatibility) -> Bool {
  self.added.length() > 0 || self.removed.length() > 0
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
  let with_added = api_changes_section(out, "Added", self.added)
  api_changes_section(with_added, "Removed", self.removed)
}

///|
pub fn api_snapshot_declarations(snapshot : String) -> Array[String] {
  api_public_declarations(snapshot)
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
fn api_difference(left : Array[String], right : Array[String]) -> Array[String] {
  let difference : Array[String] = []
  let mut index = 0
  while index < left.length() {
    if !api_array_contains(right, left[index]) {
      difference.push(left[index])
    }
    index += 1
  }
  difference
}

///|
fn api_array_contains(items : Array[String], value : String) -> Bool {
  let mut index = 0
  while index < items.length() {
    if items[index] == value {
      return true
    }
    index += 1
  }
  false
}
