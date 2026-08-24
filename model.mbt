///|
pub(all) enum ScenarioTarget {
  Native
  Js
  Wasm
  WasmGc
} derive(Debug, Eq)

///|
pub fn ScenarioTarget::name(self : ScenarioTarget) -> String {
  match self {
    Native => "native"
    Js => "js"
    Wasm => "wasm"
    WasmGc => "wasm-gc"
  }
}

///|
pub fn scenario_target(value : String) -> ScenarioTarget? {
  match ascii_lower(trim_ascii(value)) {
    "native" => Some(Native)
    "js" => Some(Js)
    "wasm" => Some(Wasm)
    "wasm-gc" => Some(WasmGc)
    _ => None
  }
}

///|
pub fn all_scenario_targets() -> Array[ScenarioTarget] {
  [Native, Js, Wasm, WasmGc]
}

///|
pub(all) enum ExpectedStatus {
  Success
  Failure
} derive(Debug, Eq)

///|
pub fn ExpectedStatus::name(self : ExpectedStatus) -> String {
  match self {
    Success => "success"
    Failure => "failure"
  }
}

///|
pub fn expected_status(value : String) -> ExpectedStatus? {
  match ascii_lower(trim_ascii(value)) {
    "success" => Some(Success)
    "pass" => Some(Success)
    "failure" => Some(Failure)
    "fail" => Some(Failure)
    _ => None
  }
}

///|
pub(all) enum ObservationStatus {
  Passed
  Failed
  Skipped
} derive(Debug, Eq)

///|
pub fn ObservationStatus::name(self : ObservationStatus) -> String {
  match self {
    Passed => "passed"
    Failed => "failed"
    Skipped => "skipped"
  }
}

///|
pub(all) enum IssueSeverity {
  Notice
  Warning
  Error
} derive(Debug, Eq)

///|
pub fn IssueSeverity::name(self : IssueSeverity) -> String {
  match self {
    Notice => "notice"
    Warning => "warning"
    Error => "error"
  }
}

///|
pub(all) struct ScenarioSpec {
  id : String
  title : String
  command : String
  targets : Array[ScenarioTarget]
  expected : ExpectedStatus
  expected_output : String
  timeout_ms : Int
  required : Bool
  tags : Array[String]
} derive(Debug, Eq)

///|
pub fn ScenarioSpec::target_names(self : ScenarioSpec) -> String {
  join_target_names(self.targets)
}

///|
pub fn ScenarioSpec::has_target(
  self : ScenarioSpec,
  target : ScenarioTarget,
) -> Bool {
  contains_target(self.targets, target)
}

///|
pub fn ScenarioSpec::has_tag(self : ScenarioSpec, tag : String) -> Bool {
  contains_string(self.tags, tag)
}

///|
pub(all) struct ScenarioObservation {
  id : String
  target : ScenarioTarget
  status : ObservationStatus
  stdout : String
  stderr : String
  duration_ms : Int
  evidence_digest : String
} derive(Debug, Eq)

///|
pub fn ScenarioObservation::is_passed(self : ScenarioObservation) -> Bool {
  self.status == Passed
}

///|
pub(all) struct ScenarioIssue {
  code : String
  severity : IssueSeverity
  scenario_id : String
  target : String
  message : String
  hint : String
} derive(Debug, Eq)

///|
pub(all) struct ScenarioManifest {
  name : String
  version : String
  specs : Array[ScenarioSpec]
  issues : Array[ScenarioIssue]
} derive(Debug, Eq)

///|
pub(all) struct ParsedScenario {
  spec : ScenarioSpec?
  issues : Array[ScenarioIssue]
} derive(Debug, Eq)

///|
pub(all) struct TargetCoverage {
  target : ScenarioTarget
  required_cases : Int
  observed_cases : Int
  passed_cases : Int
  complete : Bool
} derive(Debug, Eq)

///|
pub(all) struct ScenarioMatrix {
  name : String
  version : String
  specs : Array[ScenarioSpec]
  observations : Array[ScenarioObservation]
  coverage : Array[TargetCoverage]
  issues : Array[ScenarioIssue]
  required_count : Int
  completed_count : Int
  passed_count : Int
  failed_count : Int
  skipped_count : Int
} derive(Debug, Eq)

///|
pub fn ScenarioMatrix::passes(self : ScenarioMatrix) -> Bool {
  self.issues_have_no_errors() &&
  self.failed_count == 0 &&
  self.skipped_count == 0 &&
  self.completed_count == self.required_count
}

///|
pub fn ScenarioMatrix::issues_have_no_errors(self : ScenarioMatrix) -> Bool {
  let mut index = 0
  while index < self.issues.length() {
    if self.issues[index].severity == Error {
      return false
    }
    index += 1
  }
  true
}

///|
pub fn ScenarioMatrix::coverage_for(
  self : ScenarioMatrix,
  target : ScenarioTarget,
) -> TargetCoverage? {
  let mut index = 0
  while index < self.coverage.length() {
    if self.coverage[index].target == target {
      return Some(self.coverage[index])
    }
    index += 1
  }
  None
}

///|
pub(all) struct ScenarioDiff {
  added_ids : Array[String]
  removed_ids : Array[String]
  regressed_ids : Array[String]
  recovered_ids : Array[String]
  unchanged_count : Int
} derive(Debug, Eq)

///|
pub fn ScenarioDiff::has_regressions(self : ScenarioDiff) -> Bool {
  self.regressed_ids.length() > 0
}

///|
pub(all) struct TargetProfile {
  target : ScenarioTarget
  label : String
  supports_files : Bool
  supports_network : Bool
  supports_process : Bool
  notes : String
} derive(Debug, Eq)

///|
pub(all) struct ScenarioQuery {
  tag : String
  target : ScenarioTarget?
  status : ObservationStatus?
  required_only : Bool
} derive(Debug, Eq)

///|
pub(all) struct ScenarioStats {
  scenario_count : Int
  target_case_count : Int
  required_case_count : Int
  observed_case_count : Int
  passed_case_count : Int
  failed_case_count : Int
  missing_case_count : Int
} derive(Debug, Eq)

///|
pub(all) struct MatrixPolicy {
  required_targets : Array[ScenarioTarget]
  max_timeout_ms : Int
  require_evidence : Bool
  require_output_for_success : Bool
  allow_failure_scenarios : Bool
} derive(Debug, Eq)

///|
pub(all) struct RunPlanStep {
  index : Int
  scenario_id : String
  target : ScenarioTarget
  command : String
  expected : ExpectedStatus
  timeout_ms : Int
  required : Bool
} derive(Debug, Eq)

///|
pub(all) struct ObservationParseResult {
  observations : Array[ScenarioObservation]
  issues : Array[ScenarioIssue]
} derive(Debug, Eq)

///|
pub(all) struct ParsedObservation {
  observation : ScenarioObservation?
  issues : Array[ScenarioIssue]
} derive(Debug, Eq)

///|
pub(all) enum ScheduleLane {
  Portable
  HostBound
  Restricted
} derive(Debug, Eq)

///|
pub fn ScheduleLane::name(self : ScheduleLane) -> String {
  match self {
    Portable => "portable"
    HostBound => "host-bound"
    Restricted => "restricted"
  }
}

///|
pub(all) struct ScheduleStep {
  index : Int
  case_id : String
  target : ScenarioTarget
  lane : ScheduleLane
  command : String
  estimated_ms : Int
} derive(Debug, Eq)

///|
pub(all) struct ScheduleBatch {
  index : Int
  target : ScenarioTarget
  lane : ScheduleLane
  steps : Array[ScheduleStep]
  parallel_safe : Bool
} derive(Debug, Eq)

///|
pub(all) struct ReplayEnvelope {
  case_id : String
  target : ScenarioTarget
  command : String
  expected : ExpectedStatus
  stdout : String
  stderr : String
  duration_ms : Int
  evidence_digest : String
  replay_key : String
} derive(Debug, Eq)

///|
pub(all) struct ContractInvariant {
  code : String
  description : String
  passes : Bool
  detail : String
} derive(Debug, Eq)

///|
pub(all) struct ReproductionContract {
  matrix_name : String
  matrix_version : String
  matrix_digest : String
  policy_digest : String
  invariants : Array[ContractInvariant]
  replay_count : Int
  schedule_batch_count : Int
  passes : Bool
} derive(Debug, Eq)

///|
pub(all) enum ScenarioRiskLevel {
  Low
  Medium
  High
} derive(Debug, Eq)

///|
pub fn ScenarioRiskLevel::name(self : ScenarioRiskLevel) -> String {
  match self {
    Low => "low"
    Medium => "medium"
    High => "high"
  }
}

///|
pub(all) struct ScenarioRiskFinding {
  scenario_id : String
  target : ScenarioTarget
  level : ScenarioRiskLevel
  code : String
  message : String
  hint : String
} derive(Debug, Eq)

///|
pub(all) struct ScenarioRiskReport {
  findings : Array[ScenarioRiskFinding]
  low_count : Int
  medium_count : Int
  high_count : Int
  passes : Bool
} derive(Debug, Eq)

///|
pub(all) struct MatrixSnapshot {
  label : String
  digest : String
  required_count : Int
  passed_count : Int
  failed_count : Int
  skipped_count : Int
  ready : Bool
} derive(Debug, Eq)

///|
pub(all) struct MatrixTimeline {
  snapshots : Array[MatrixSnapshot]
  improved : Int
  regressed : Int
  stable : Int
} derive(Debug, Eq)

///|
pub(all) struct ScenarioMetrics {
  scenario_count : Int
  target_case_count : Int
  observed_case_count : Int
  covered_target_count : Int
  required_target_count : Int
  passed_count : Int
  failed_count : Int
  skipped_count : Int
  total_duration_ms : Int
  min_duration_ms : Int
  max_duration_ms : Int
  coverage_percent : Int
  pass_percent : Int
  balance_score : Int
} derive(Debug, Eq)

///|
fn scenario_issue(
  code : String,
  severity : IssueSeverity,
  scenario_id : String,
  target : String,
  message : String,
  hint : String,
) -> ScenarioIssue {
  ScenarioIssue::{ code, severity, scenario_id, target, message, hint }
}

///|
fn contains_target(
  items : Array[ScenarioTarget],
  value : ScenarioTarget,
) -> Bool {
  let mut index = 0
  while index < items.length() {
    if items[index] == value {
      return true
    }
    index += 1
  }
  false
}

///|
fn contains_string(items : Array[String], value : String) -> Bool {
  let mut index = 0
  while index < items.length() {
    if items[index] == value {
      return true
    }
    index += 1
  }
  false
}

///|
fn join_target_names(items : Array[ScenarioTarget]) -> String {
  let mut out = ""
  let mut index = 0
  while index < items.length() {
    if index > 0 {
      out = out + ","
    }
    out = out + items[index].name()
    index += 1
  }
  out
}

///|
fn join_strings(items : Array[String], separator : String) -> String {
  let mut out = ""
  let mut index = 0
  while index < items.length() {
    if index > 0 {
      out = out + separator
    }
    out = out + items[index]
    index += 1
  }
  out
}
