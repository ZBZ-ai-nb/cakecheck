///|
pub fn build_reproduction_contract(
  matrix : ScenarioMatrix,
  policy : MatrixPolicy,
) -> ReproductionContract {
  let replay = build_replay_envelopes(matrix)
  let schedule = build_schedule(matrix)
  let invariants : Array[ContractInvariant] = []
  invariants.push(ContractInvariant::{
    code: "matrix-passes",
    description: "all required scenario cases have matching observations",
    passes: matrix.passes(),
    detail: scenario_matrix_summary(matrix),
  })
  invariants.push(ContractInvariant::{
    code: "target-coverage",
    description: "every selected target has required coverage",
    passes: matrix.required_targets_complete(),
    detail: coverage_detail(matrix.coverage),
  })
  invariants.push(ContractInvariant::{
    code: "replay-keys-unique",
    description: "every observed case has one stable replay key",
    passes: replay_envelopes_are_unique(replay),
    detail: "replays=" + replay.length().to_string(),
  })
  invariants.push(ContractInvariant::{
    code: "schedule-deterministic",
    description: "target batches and steps have stable ordering",
    passes: schedule_is_deterministic(schedule),
    detail: "batches=" + schedule.length().to_string(),
  })
  invariants.push(ContractInvariant::{
    code: "policy-output",
    description: "selected matrix policy has no blocking issues",
    passes: apply_policy(matrix, policy).passes(),
    detail: policy_summary(policy),
  })
  invariants.push(ContractInvariant::{
    code: "evidence-digest",
    description: "matrix and replay evidence have deterministic digests",
    passes: digest_is_well_formed(digest_for_matrix(matrix)) &&
    digest_is_well_formed(replay_envelopes_digest(replay)),
    detail: "matrix=" + digest_for_matrix(matrix),
  })
  let mut passes = true
  let mut index = 0
  while index < invariants.length() {
    if !invariants[index].passes {
      passes = false
    }
    index += 1
  }
  ReproductionContract::{
    matrix_name: matrix.name,
    matrix_version: matrix.version,
    matrix_digest: digest_for_matrix(matrix),
    policy_digest: scenario_evidence_digest(policy_summary(policy), ""),
    invariants,
    replay_count: replay.length(),
    schedule_batch_count: schedule.length(),
    passes,
  }
}

///|
pub fn ReproductionContract::is_ready(self : ReproductionContract) -> Bool {
  self.passes
}

///|
pub fn ReproductionContract::summary(self : ReproductionContract) -> String {
  "contract=" +
  bool_text(self.passes) +
  ", matrix=" +
  self.matrix_name +
  ", version=" +
  self.matrix_version +
  ", invariants=" +
  self.invariants.length().to_string() +
  ", replays=" +
  self.replay_count.to_string() +
  ", batches=" +
  self.schedule_batch_count.to_string()
}

///|
pub fn ReproductionContract::to_markdown(self : ReproductionContract) -> String {
  let mut out = "# Reproduction Contract\n\n"
  out = out + "- Matrix: `" + self.matrix_name + "`\n"
  out = out + "- Version: `" + self.matrix_version + "`\n"
  out = out + "- Ready: " + bool_text(self.passes) + "\n"
  out = out + "- Matrix digest: `" + self.matrix_digest + "`\n"
  out = out + "- Policy digest: `" + self.policy_digest + "`\n"
  out = out + "- Replay envelopes: " + self.replay_count.to_string() + "\n"
  out = out +
    "- Schedule batches: " +
    self.schedule_batch_count.to_string() +
    "\n\n"
  out = out +
    "| Code | Passes | Invariant | Detail |\n| --- | --- | --- | --- |\n"
  let mut index = 0
  while index < self.invariants.length() {
    let invariant = self.invariants[index]
    out = out + "| `" + invariant.code + "` | " + bool_text(invariant.passes)
    out = out +
      " | " +
      invariant.description +
      " | " +
      invariant.detail +
      " |\n"
    index += 1
  }
  out
}

///|
pub fn ReproductionContract::to_json(self : ReproductionContract) -> String {
  let mut out = "{\"matrix\":\"" + json_escape(self.matrix_name) + "\","
  out = out + "\"version\":\"" + json_escape(self.matrix_version) + "\","
  out = out + "\"passes\":" + bool_text(self.passes) + ","
  out = out + "\"matrix_digest\":\"" + self.matrix_digest + "\","
  out = out + "\"policy_digest\":\"" + self.policy_digest + "\","
  out = out + "\"replays\":" + self.replay_count.to_string() + ","
  out = out + "\"batches\":" + self.schedule_batch_count.to_string() + ","
  out = out + "\"invariants\":["
  let mut index = 0
  while index < self.invariants.length() {
    if index > 0 {
      out = out + ","
    }
    let invariant = self.invariants[index]
    out = out + "{\"code\":\"" + invariant.code + "\","
    out = out + "\"passes\":" + bool_text(invariant.passes) + ","
    out = out + "\"detail\":\"" + json_escape(invariant.detail) + "\"}"
    index += 1
  }
  out + "]}"
}

///|
pub fn contract_invariant(
  contract : ReproductionContract,
  code : String,
) -> ContractInvariant? {
  let mut index = 0
  while index < contract.invariants.length() {
    if contract.invariants[index].code == code {
      return Some(contract.invariants[index])
    }
    index += 1
  }
  None
}

///|
fn coverage_detail(coverage : Array[TargetCoverage]) -> String {
  let parts : Array[String] = []
  let mut index = 0
  while index < coverage.length() {
    let item = coverage[index]
    parts.push(
      item.target.name() +
      "=" +
      item.passed_cases.to_string() +
      "/" +
      item.required_cases.to_string(),
    )
    index += 1
  }
  join_strings(parts, ",")
}
