///|
pub fn query_scenario_ids(
  matrix : ScenarioMatrix,
  query : ScenarioQuery,
) -> Array[String] {
  let result : Array[String] = []
  let mut spec_index = 0
  while spec_index < matrix.specs.length() {
    let spec = matrix.specs[spec_index]
    if query.required_only && !spec.required {
      spec_index += 1
      continue
    }
    if query.tag.length() > 0 && !spec.has_tag(query.tag) {
      spec_index += 1
      continue
    }
    let mut target_index = 0
    while target_index < spec.targets.length() {
      let target = spec.targets[target_index]
      let target_ok = match query.target {
        None => true
        Some(value) => value == target
      }
      if target_ok {
        let status_ok = match query.status {
          None => true
          Some(status) =>
            match observation_for(matrix.observations, spec.id, target) {
              None => status == Skipped
              Some(observation) => observation.status == status
            }
        }
        if status_ok {
          result.push(scenario_case_key(spec.id, target))
        }
      }
      target_index += 1
    }
    spec_index += 1
  }
  result
}

///|
pub fn scenario_stats(matrix : ScenarioMatrix) -> ScenarioStats {
  let mut target_case_count = 0
  let mut required_case_count = 0
  let mut observed_case_count = 0
  let mut passed_case_count = 0
  let mut failed_case_count = 0
  let mut missing_case_count = 0
  let mut spec_index = 0
  while spec_index < matrix.specs.length() {
    let spec = matrix.specs[spec_index]
    target_case_count += spec.targets.length()
    if spec.required {
      required_case_count += spec.targets.length()
    }
    let mut target_index = 0
    while target_index < spec.targets.length() {
      let target = spec.targets[target_index]
      match observation_for(matrix.observations, spec.id, target) {
        None => missing_case_count += 1
        Some(observation) => {
          observed_case_count += 1
          if observation_matches(spec, observation) {
            passed_case_count += 1
          } else {
            failed_case_count += 1
          }
        }
      }
      target_index += 1
    }
    spec_index += 1
  }
  ScenarioStats::{
    scenario_count: matrix.specs.length(),
    target_case_count,
    required_case_count,
    observed_case_count,
    passed_case_count,
    failed_case_count,
    missing_case_count,
  }
}

///|
pub fn stats_summary(stats : ScenarioStats) -> String {
  "scenarios=" +
  stats.scenario_count.to_string() +
  ", cases=" +
  stats.target_case_count.to_string() +
  ", required=" +
  stats.required_case_count.to_string() +
  ", observed=" +
  stats.observed_case_count.to_string() +
  ", passed=" +
  stats.passed_case_count.to_string() +
  ", failed=" +
  stats.failed_case_count.to_string() +
  ", missing=" +
  stats.missing_case_count.to_string()
}

///|
pub fn query_summary(matrix : ScenarioMatrix, query : ScenarioQuery) -> String {
  let ids = query_scenario_ids(matrix, query)
  "matched=" + ids.length().to_string() + ": " + join_strings(ids, ", ")
}

///|
pub fn all_case_ids(matrix : ScenarioMatrix) -> Array[String] {
  query_scenario_ids(matrix, ScenarioQuery::{
    tag: "",
    target: None,
    status: None,
    required_only: false,
  })
}

///|
pub fn required_case_ids(matrix : ScenarioMatrix) -> Array[String] {
  query_scenario_ids(matrix, ScenarioQuery::{
    tag: "",
    target: None,
    status: None,
    required_only: true,
  })
}

///|
pub fn target_case_ids(
  matrix : ScenarioMatrix,
  target : ScenarioTarget,
) -> Array[String] {
  query_scenario_ids(matrix, ScenarioQuery::{
    tag: "",
    target: Some(target),
    status: None,
    required_only: false,
  })
}

///|
pub fn tag_case_ids(matrix : ScenarioMatrix, tag : String) -> Array[String] {
  query_scenario_ids(matrix, ScenarioQuery::{
    tag,
    target: None,
    status: None,
    required_only: false,
  })
}

///|
pub fn failed_case_ids(matrix : ScenarioMatrix) -> Array[String] {
  query_scenario_ids(matrix, ScenarioQuery::{
    tag: "",
    target: None,
    status: Some(Failed),
    required_only: false,
  })
}

///|
pub fn skipped_case_ids(matrix : ScenarioMatrix) -> Array[String] {
  query_scenario_ids(matrix, ScenarioQuery::{
    tag: "",
    target: None,
    status: Some(Skipped),
    required_only: false,
  })
}
