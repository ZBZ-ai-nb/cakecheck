///|
pub fn build_scenario_matrix(
  manifest : ScenarioManifest,
  observations : Array[ScenarioObservation],
  required_targets : Array[ScenarioTarget],
) -> ScenarioMatrix {
  let specs = manifest.specs
  let issues : Array[ScenarioIssue] = []
  let coverage : Array[TargetCoverage] = []
  let mut required_count = 0
  let mut completed_count = 0
  let mut passed_count = 0
  let mut failed_count = 0
  let mut skipped_count = 0
  let mut issue_index = 0
  while issue_index < manifest.issues.length() {
    issues.push(manifest.issues[issue_index])
    issue_index += 1
  }
  validate_duplicate_specs(specs, issues)
  validate_duplicate_observations(observations, issues)
  let mut spec_index = 0
  while spec_index < specs.length() {
    let spec = specs[spec_index]
    let mut target_index = 0
    while target_index < spec.targets.length() {
      let target = spec.targets[target_index]
      if spec.required {
        required_count += 1
      }
      match observation_for(observations, spec.id, target) {
        None => {
          skipped_count += 1
          issues.push(
            scenario_issue(
              "observation-missing",
              if spec.required {
                Error
              } else {
                Notice
              },
              spec.id,
              target.name(),
              "no run observation was recorded for this scenario target",
              "Run the declared command and record its output and evidence digest.",
            ),
          )
        }
        Some(observation) => {
          completed_count += if spec.required { 1 } else { 0 }
          if observation_matches(spec, observation) {
            passed_count += 1
          } else {
            failed_count += 1
            let observation_issues = validate_observation(spec, observation)
            let mut observation_issue_index = 0
            while observation_issue_index < observation_issues.length() {
              issues.push(observation_issues[observation_issue_index])
              observation_issue_index += 1
            }
          }
        }
      }
      target_index += 1
    }
    spec_index += 1
  }
  let mut target_index = 0
  while target_index < required_targets.length() {
    let target = required_targets[target_index]
    coverage.push(compute_coverage(specs, observations, target))
    if !coverage[coverage.length() - 1].complete {
      issues.push(
        scenario_issue(
          "target-coverage-incomplete",
          Error,
          "",
          target.name(),
          "required target coverage is incomplete",
          "Record every required scenario for this target before publishing the matrix.",
        ),
      )
    }
    target_index += 1
  }
  ScenarioMatrix::{
    name: manifest.name,
    version: manifest.version,
    specs,
    observations,
    coverage,
    issues,
    required_count,
    completed_count,
    passed_count,
    failed_count,
    skipped_count,
  }
}

///|
pub fn observation_for(
  observations : Array[ScenarioObservation],
  id : String,
  target : ScenarioTarget,
) -> ScenarioObservation? {
  let mut index = 0
  while index < observations.length() {
    if observations[index].id == id && observations[index].target == target {
      return Some(observations[index])
    }
    index += 1
  }
  None
}

///|
fn validate_duplicate_specs(
  specs : Array[ScenarioSpec],
  issues : Array[ScenarioIssue],
) -> Unit {
  let mut left = 0
  while left < specs.length() {
    let mut right = left + 1
    while right < specs.length() {
      if specs[left].id == specs[right].id {
        issues.push(
          scenario_issue(
            "scenario-id-duplicate",
            Error,
            specs[left].id,
            "",
            "scenario id is declared more than once",
            "Give each scenario one stable id so observations can be joined safely.",
          ),
        )
      }
      right += 1
    }
    left += 1
  }
}

///|
fn validate_duplicate_observations(
  observations : Array[ScenarioObservation],
  issues : Array[ScenarioIssue],
) -> Unit {
  let mut left = 0
  while left < observations.length() {
    let mut right = left + 1
    while right < observations.length() {
      let first = observations[left]
      let second = observations[right]
      if first.id == second.id && first.target == second.target {
        issues.push(
          scenario_issue(
            "observation-duplicate",
            Error,
            first.id,
            first.target.name(),
            "more than one observation matches the same scenario target",
            "Keep one deterministic observation row per id and target.",
          ),
        )
      }
      right += 1
    }
    left += 1
  }
}

///|
fn observation_matches(
  spec : ScenarioSpec,
  observation : ScenarioObservation,
) -> Bool {
  let status_ok = match spec.expected {
    Success => observation.status == Passed
    Failure => observation.status == Failed
  }
  let output_ok = spec.expected_output.length() == 0 ||
    contains(observation.stdout, spec.expected_output)
  let duration_ok = observation.duration_ms >= 0 &&
    observation.duration_ms <= spec.timeout_ms
  let evidence_ok = observation.evidence_digest.length() > 0
  status_ok && output_ok && duration_ok && evidence_ok
}

///|
fn compute_coverage(
  specs : Array[ScenarioSpec],
  observations : Array[ScenarioObservation],
  target : ScenarioTarget,
) -> TargetCoverage {
  let mut required_cases = 0
  let mut observed_cases = 0
  let mut passed_cases = 0
  let mut spec_index = 0
  while spec_index < specs.length() {
    let spec = specs[spec_index]
    if spec.required && spec.has_target(target) {
      required_cases += 1
      match observation_for(observations, spec.id, target) {
        None => ()
        Some(observation) => {
          observed_cases += 1
          if observation_matches(spec, observation) {
            passed_cases += 1
          }
        }
      }
    }
    spec_index += 1
  }
  TargetCoverage::{
    target,
    required_cases,
    observed_cases,
    passed_cases,
    complete: required_cases > 0 && required_cases == passed_cases,
  }
}

///|
pub fn validate_observation(
  spec : ScenarioSpec,
  observation : ScenarioObservation,
) -> Array[ScenarioIssue] {
  let issues : Array[ScenarioIssue] = []
  if !contains_target(spec.targets, observation.target) {
    issues.push(
      scenario_issue(
        "observation-target-unexpected",
        Error,
        spec.id,
        observation.target.name(),
        "observation target is not declared by the scenario",
        "Add the target to the scenario or remove the observation.",
      ),
    )
  }
  match spec.expected {
    Success =>
      if observation.status != Passed {
        issues.push(
          scenario_issue(
            "observation-status-mismatch",
            Error,
            spec.id,
            observation.target.name(),
            "scenario expected success but observation did not pass",
            "Inspect stderr and record a passing run for a success scenario.",
          ),
        )
      }
    Failure =>
      if observation.status != Failed {
        issues.push(
          scenario_issue(
            "observation-status-mismatch",
            Error,
            spec.id,
            observation.target.name(),
            "scenario expected failure but observation did not fail",
            "Use a deterministic failing fixture when documenting failure behavior.",
          ),
        )
      }
  }
  if spec.expected_output.length() > 0 &&
    !contains(observation.stdout, spec.expected_output) {
    issues.push(
      scenario_issue(
        "observation-output-mismatch",
        Error,
        spec.id,
        observation.target.name(),
        "observed stdout does not contain the declared output fragment",
        "Record the stable output fragment that proves the scenario behavior.",
      ),
    )
  }
  if observation.duration_ms < 0 || observation.duration_ms > spec.timeout_ms {
    issues.push(
      scenario_issue(
        "observation-timeout",
        Error,
        spec.id,
        observation.target.name(),
        "observed duration is outside the declared timeout",
        "Use a bounded run and record duration in milliseconds.",
      ),
    )
  }
  if !digest_is_well_formed(observation.evidence_digest) {
    issues.push(
      scenario_issue(
        "observation-evidence-missing",
        Error,
        spec.id,
        observation.target.name(),
        "observation has no deterministic evidence digest",
        "Hash the stable stdout/stderr evidence with scenario_evidence_digest.",
      ),
    )
  }
  issues
}

///|
pub fn scenario_matrix_summary(matrix : ScenarioMatrix) -> String {
  "matrix=" +
  matrix.name +
  ", version=" +
  matrix.version +
  ", passed=" +
  matrix.passed_count.to_string() +
  ", failed=" +
  matrix.failed_count.to_string() +
  ", skipped=" +
  matrix.skipped_count.to_string() +
  ", required=" +
  matrix.required_count.to_string() +
  ", complete=" +
  bool_text(matrix.passes())
}

///|
pub fn ScenarioMatrix::issue_count(
  self : ScenarioMatrix,
  severity : IssueSeverity,
) -> Int {
  let mut count = 0
  let mut index = 0
  while index < self.issues.length() {
    if self.issues[index].severity == severity {
      count += 1
    }
    index += 1
  }
  count
}

///|
pub fn ScenarioMatrix::required_targets_complete(self : ScenarioMatrix) -> Bool {
  let mut index = 0
  while index < self.coverage.length() {
    if !self.coverage[index].complete {
      return false
    }
    index += 1
  }
  true
}
