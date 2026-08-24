///|
pub fn diff_scenario_matrices(
  before : ScenarioMatrix,
  after : ScenarioMatrix,
) -> ScenarioDiff {
  let added : Array[String] = []
  let removed : Array[String] = []
  let regressed : Array[String] = []
  let recovered : Array[String] = []
  let mut unchanged = 0
  let mut after_spec_index = 0
  while after_spec_index < after.specs.length() {
    let spec = after.specs[after_spec_index]
    let mut target_index = 0
    while target_index < spec.targets.length() {
      let target = spec.targets[target_index]
      let key = scenario_case_key(spec.id, target)
      if !matrix_has_case(before, spec.id, target) {
        added.push(key)
      } else {
        let before_passed = matrix_case_passed(before, spec.id, target)
        let after_passed = matrix_case_passed(after, spec.id, target)
        if before_passed && !after_passed {
          regressed.push(key)
        } else if !before_passed && after_passed {
          recovered.push(key)
        } else {
          unchanged += 1
        }
      }
      target_index += 1
    }
    after_spec_index += 1
  }
  let mut before_spec_index = 0
  while before_spec_index < before.specs.length() {
    let spec = before.specs[before_spec_index]
    let mut target_index = 0
    while target_index < spec.targets.length() {
      let target = spec.targets[target_index]
      if !matrix_has_case(after, spec.id, target) {
        removed.push(scenario_case_key(spec.id, target))
      }
      target_index += 1
    }
    before_spec_index += 1
  }
  ScenarioDiff::{
    added_ids: added,
    removed_ids: removed,
    regressed_ids: regressed,
    recovered_ids: recovered,
    unchanged_count: unchanged,
  }
}

///|
pub fn ScenarioDiff::summary(self : ScenarioDiff) -> String {
  "added=" +
  self.added_ids.length().to_string() +
  ", removed=" +
  self.removed_ids.length().to_string() +
  ", regressed=" +
  self.regressed_ids.length().to_string() +
  ", recovered=" +
  self.recovered_ids.length().to_string() +
  ", unchanged=" +
  self.unchanged_count.to_string()
}

///|
pub fn ScenarioDiff::to_markdown(self : ScenarioDiff) -> String {
  let mut out = "# Scenario Matrix Diff\n\n"
  out = out + "- Added: " + self.added_ids.length().to_string() + "\n"
  out = out + "- Removed: " + self.removed_ids.length().to_string() + "\n"
  out = out + "- Regressed: " + self.regressed_ids.length().to_string() + "\n"
  out = out + "- Recovered: " + self.recovered_ids.length().to_string() + "\n"
  out = out + "- Unchanged: " + self.unchanged_count.to_string() + "\n\n"
  out = out + diff_list("Added", self.added_ids)
  out = out + diff_list("Removed", self.removed_ids)
  out = out + diff_list("Regressed", self.regressed_ids)
  out + diff_list("Recovered", self.recovered_ids)
}

///|
pub fn ScenarioDiff::to_json(self : ScenarioDiff) -> String {
  "{\"added\":" +
  string_array_json(self.added_ids) +
  ",\"removed\":" +
  string_array_json(self.removed_ids) +
  ",\"regressed\":" +
  string_array_json(self.regressed_ids) +
  ",\"recovered\":" +
  string_array_json(self.recovered_ids) +
  ",\"unchanged\":" +
  self.unchanged_count.to_string() +
  "}"
}

///|
fn matrix_has_case(
  matrix : ScenarioMatrix,
  id : String,
  target : ScenarioTarget,
) -> Bool {
  let mut index = 0
  while index < matrix.specs.length() {
    if matrix.specs[index].id == id && matrix.specs[index].has_target(target) {
      return true
    }
    index += 1
  }
  false
}

///|
fn matrix_case_passed(
  matrix : ScenarioMatrix,
  id : String,
  target : ScenarioTarget,
) -> Bool {
  match find_spec(matrix.specs, id) {
    None => false
    Some(spec) =>
      match observation_for(matrix.observations, id, target) {
        None => false
        Some(observation) => observation_matches(spec, observation)
      }
  }
}

///|
fn find_spec(specs : Array[ScenarioSpec], id : String) -> ScenarioSpec? {
  let mut index = 0
  while index < specs.length() {
    if specs[index].id == id {
      return Some(specs[index])
    }
    index += 1
  }
  None
}

///|
fn scenario_case_key(id : String, target : ScenarioTarget) -> String {
  id + "@" + target.name()
}

///|
fn diff_list(title : String, items : Array[String]) -> String {
  let mut out = "## " + title + "\n\n"
  if items.length() == 0 {
    return out + "- None\n\n"
  }
  let mut index = 0
  while index < items.length() {
    out = out + "- `" + items[index] + "`\n"
    index += 1
  }
  out + "\n"
}

///|
fn string_array_json(items : Array[String]) -> String {
  let mut out = "["
  let mut index = 0
  while index < items.length() {
    if index > 0 {
      out = out + ","
    }
    out = out + "\"" + json_escape(items[index]) + "\""
    index += 1
  }
  out + "]"
}
