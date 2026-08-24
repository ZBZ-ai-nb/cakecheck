///|
pub fn default_matrix_policy() -> MatrixPolicy {
  MatrixPolicy::{
    required_targets: [Native, Js, Wasm],
    max_timeout_ms: 120000,
    require_evidence: true,
    require_output_for_success: true,
    allow_failure_scenarios: true,
  }
}

///|
pub fn strict_matrix_policy() -> MatrixPolicy {
  MatrixPolicy::{
    required_targets: [Native, Js, Wasm, WasmGc],
    max_timeout_ms: 60000,
    require_evidence: true,
    require_output_for_success: true,
    allow_failure_scenarios: false,
  }
}

///|
pub fn policy_issues(
  manifest : ScenarioManifest,
  policy : MatrixPolicy,
) -> Array[ScenarioIssue] {
  let issues : Array[ScenarioIssue] = []
  let mut spec_index = 0
  while spec_index < manifest.specs.length() {
    let spec = manifest.specs[spec_index]
    if spec.timeout_ms > policy.max_timeout_ms {
      issues.push(
        scenario_issue(
          "policy-timeout-too-large",
          Error,
          spec.id,
          "",
          "scenario timeout exceeds the selected policy",
          "Use a bounded timeout or choose a policy with an explicit larger limit.",
        ),
      )
    }
    if !policy.allow_failure_scenarios && spec.expected == Failure {
      issues.push(
        scenario_issue(
          "policy-failure-scenario-disabled",
          Error,
          spec.id,
          "",
          "selected policy does not allow expected-failure scenarios",
          "Use expected=success in the strict smoke matrix.",
        ),
      )
    }
    if policy.require_output_for_success &&
      spec.expected == Success &&
      spec.expected_output.length() == 0 {
      issues.push(
        scenario_issue(
          "policy-output-missing",
          Error,
          spec.id,
          "",
          "success scenario has no stable output fragment",
          "Declare output=... so a passing run has observable evidence.",
        ),
      )
    }
    spec_index += 1
  }
  let mut target_index = 0
  while target_index < policy.required_targets.length() {
    let target = policy.required_targets[target_index]
    if !manifest_has_required_target(manifest.specs, target) {
      issues.push(
        scenario_issue(
          "policy-target-not-covered",
          Error,
          "",
          target.name(),
          "no required scenario covers a policy target",
          "Add at least one required scenario for every selected target.",
        ),
      )
    }
    target_index += 1
  }
  if manifest.specs.length() == 0 {
    issues.push(
      scenario_issue(
        "policy-no-scenarios",
        Error,
        "",
        "",
        "policy cannot be evaluated against an empty manifest",
        "Declare at least one scenario.",
      ),
    )
  }
  issues
}

///|
pub fn apply_policy(
  matrix : ScenarioMatrix,
  policy : MatrixPolicy,
) -> ScenarioMatrix {
  let result = matrix
  let policy_result = policy_issues(
    ScenarioManifest::{
      name: matrix.name,
      version: matrix.version,
      specs: matrix.specs,
      issues: [],
    },
    policy,
  )
  let mut index = 0
  while index < policy_result.length() {
    result.issues.push(policy_result[index])
    index += 1
  }
  if policy.require_evidence {
    index = 0
    while index < result.observations.length() {
      let observation = result.observations[index]
      if observation.evidence_digest.length() == 0 {
        result.issues.push(
          scenario_issue(
            "policy-evidence-missing",
            Error,
            observation.id,
            observation.target.name(),
            "policy requires a digest for every observation",
            "Record scenario_evidence_digest(stdout, stderr) with the observation.",
          ),
        )
      }
      index += 1
    }
  }
  result
}

///|
fn manifest_has_required_target(
  specs : Array[ScenarioSpec],
  target : ScenarioTarget,
) -> Bool {
  let mut index = 0
  while index < specs.length() {
    if specs[index].required && specs[index].has_target(target) {
      return true
    }
    index += 1
  }
  false
}

///|
pub fn policy_summary(policy : MatrixPolicy) -> String {
  "targets=" +
  join_target_names(policy.required_targets) +
  ", max-timeout-ms=" +
  policy.max_timeout_ms.to_string() +
  ", require-evidence=" +
  bool_text(policy.require_evidence) +
  ", require-output=" +
  bool_text(policy.require_output_for_success) +
  ", allow-failure=" +
  bool_text(policy.allow_failure_scenarios)
}

///|
pub fn policy_markdown(policy : MatrixPolicy) -> String {
  "| Rule | Value |\n| --- | --- |\n" +
  "| Required targets | `" +
  join_target_names(policy.required_targets) +
  "` |\n" +
  "| Maximum timeout | " +
  policy.max_timeout_ms.to_string() +
  " ms |\n" +
  "| Evidence required | " +
  bool_text(policy.require_evidence) +
  " |\n" +
  "| Output required | " +
  bool_text(policy.require_output_for_success) +
  " |\n" +
  "| Failure scenarios allowed | " +
  bool_text(policy.allow_failure_scenarios) +
  " |\n"
}
