///|
pub(all) enum ApiMigrationRisk {
  Informational
  ReviewRequired
  Breaking
} derive(Debug, Eq)

///|
pub(all) enum ApiMigrationAction {
  Adopt
  Migrate
  Replace
} derive(Debug, Eq)

///|
pub(all) struct ApiMigrationItem {
  id : String
  kind : ApiChangeKind
  identity : String
  risk : ApiMigrationRisk
  action : ApiMigrationAction
  detail : String
} derive(Debug, Eq)

///|
pub(all) struct ApiMigrationPlan {
  items : Array[ApiMigrationItem]
  breaking_count : Int
  advisory_count : Int
  migration_required : Bool
} derive(Debug, Eq)

///|
pub fn ApiMigrationRisk::name(self : ApiMigrationRisk) -> String {
  match self {
    Informational => "informational"
    ReviewRequired => "review-required"
    Breaking => "breaking"
  }
}

///|
pub fn ApiMigrationAction::name(self : ApiMigrationAction) -> String {
  match self {
    Adopt => "adopt"
    Migrate => "migrate"
    Replace => "replace"
  }
}

///|
pub fn ApiMigrationItem::summary(self : ApiMigrationItem) -> String {
  self.id + " " + self.risk.name() + " -> " + self.action.name()
}

///|
pub fn build_api_migration_plan(
  compatibility : ApiCompatibility,
) -> ApiMigrationPlan {
  let items : Array[ApiMigrationItem] = []
  let mut index = 0
  while index < compatibility.added.length() {
    let declaration = compatibility.added[index]
    let identity = api_declaration_identity(declaration)
    items.push(ApiMigrationItem::{
      id: "added:" + identity,
      kind: Added,
      identity,
      risk: Informational,
      action: Adopt,
      detail: "new public declaration; existing callers do not need migration",
    })
    index += 1
  }
  index = 0
  while index < compatibility.changed.length() {
    let change = compatibility.changed[index]
    items.push(ApiMigrationItem::{
      id: "changed:" + change.identity,
      kind: Changed,
      identity: change.identity,
      risk: Breaking,
      action: Migrate,
      detail: "existing callers must review the changed public contract",
    })
    index += 1
  }
  index = 0
  while index < compatibility.removed.length() {
    let declaration = compatibility.removed[index]
    let identity = api_declaration_identity(declaration)
    items.push(ApiMigrationItem::{
      id: "removed:" + identity,
      kind: Removed,
      identity,
      risk: Breaking,
      action: Replace,
      detail: "provide a replacement or migration note before removal",
    })
    index += 1
  }
  let breaking_count = compatibility.changed.length() +
    compatibility.removed.length()
  ApiMigrationPlan::{
    items,
    breaking_count,
    advisory_count: compatibility.added.length(),
    migration_required: breaking_count > 0,
  }
}

///|
pub fn ApiMigrationPlan::has_breaking_changes(self : ApiMigrationPlan) -> Bool {
  self.breaking_count > 0
}

///|
pub fn ApiMigrationPlan::summary(self : ApiMigrationPlan) -> String {
  "migration-required=" +
  bool_text(self.migration_required) +
  ", breaking=" +
  self.breaking_count.to_string() +
  ", advisory=" +
  self.advisory_count.to_string() +
  ", items=" +
  self.items.length().to_string()
}

///|
pub fn ApiMigrationPlan::to_markdown(self : ApiMigrationPlan) -> String {
  let mut out = "## API Migration Ledger\n\n"
  out = out +
    "- Migration required: " +
    bool_text(self.migration_required) +
    "\n"
  out = out + "- Breaking items: " + self.breaking_count.to_string() + "\n"
  out = out + "- Advisory items: " + self.advisory_count.to_string() + "\n\n"
  out = out + "| ID | Change | Risk | Action | Detail |\n"
  out = out + "| --- | --- | --- | --- | --- |\n"
  let mut index = 0
  while index < self.items.length() {
    let item = self.items[index]
    out = out + "| `" + item.id + "`"
    out = out + " | " + api_change_kind_name(item.kind)
    out = out + " | " + item.risk.name()
    out = out + " | " + item.action.name()
    out = out + " | " + item.detail + " |\n"
    index += 1
  }
  out
}

///|
pub fn ApiMigrationPlan::to_json(self : ApiMigrationPlan) -> String {
  let mut out = "{"
  out = out +
    "\"migration_required\":" +
    api_json_bool(self.migration_required) +
    ","
  out = out + "\"breaking\":" + self.breaking_count.to_string() + ","
  out = out + "\"advisory\":" + self.advisory_count.to_string() + ","
  out = out + "\"items\":["
  let mut index = 0
  while index < self.items.length() {
    if index > 0 {
      out = out + ","
    }
    let item = self.items[index]
    out = out + "{\"id\":\"" + json_escape(item.id) + "\","
    out = out + "\"risk\":\"" + item.risk.name() + "\","
    out = out + "\"action\":\"" + item.action.name() + "\"}"
    index += 1
  }
  out + "]}"
}

///|
fn api_change_kind_name(kind : ApiChangeKind) -> String {
  match kind {
    Added => "added"
    Removed => "removed"
    Changed => "changed"
  }
}
