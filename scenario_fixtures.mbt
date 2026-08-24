///|
pub(all) enum ScenarioFixtureKind {
  Minimal
  CrossTarget
  ExpectedFailure
  RestrictedTarget
} derive(Debug, Eq)

///|
pub fn ScenarioFixtureKind::name(self : ScenarioFixtureKind) -> String {
  match self {
    Minimal => "minimal"
    CrossTarget => "cross-target"
    ExpectedFailure => "expected-failure"
    RestrictedTarget => "restricted-target"
  }
}

///|
pub fn scenario_fixture_source(kind : ScenarioFixtureKind) -> String {
  match kind {
    Minimal =>
      "matrix name=minimal version=0.3.0\n" +
      "scenario id=hello title=hello command=\"moon run examples/basic\" " +
      "targets=native expected=success output=\"hello world\" timeout_ms=30000 " +
      "required=true tags=smoke\n"
    CrossTarget =>
      "matrix name=cross-target version=0.3.0\n" +
      "scenario id=hello title=hello command=\"moon run examples/basic\" " +
      "targets=native,js,wasm expected=success output=\"hello world\" " +
      "timeout_ms=30000 required=true tags=smoke,portable\n" +
      "scenario id=fmt title=format command=\"moon fmt --check\" targets=native " +
      "expected=success output=\"format ok\" timeout_ms=30000 required=true tags=quality\n"
    ExpectedFailure =>
      "matrix name=expected-failure version=0.3.0\n" +
      "scenario id=invalid title=invalid-input command=\"moon run examples/invalid\" " +
      "targets=native,js expected=failure output=\"invalid input\" timeout_ms=10000 " +
      "required=true tags=negative\n"
    RestrictedTarget =>
      "matrix name=restricted version=0.3.0\n" +
      "scenario id=portable title=portable command=\"moon run examples/basic\" " +
      "targets=wasm,wasm-gc expected=success output=\"hello world\" timeout_ms=30000 " +
      "required=true tags=portable\n"
  }
}

///|
pub fn scenario_fixture_manifest(
  kind : ScenarioFixtureKind,
) -> ScenarioManifest {
  parse_scenario_manifest(scenario_fixture_source(kind))
}

///|
pub fn scenario_fixture_targets(
  kind : ScenarioFixtureKind,
) -> Array[ScenarioTarget] {
  match kind {
    Minimal => [Native]
    CrossTarget => [Native, Js, Wasm]
    ExpectedFailure => [Native, Js]
    RestrictedTarget => [Wasm, WasmGc]
  }
}

///|
pub fn scenario_fixture_observations(
  kind : ScenarioFixtureKind,
) -> Array[ScenarioObservation] {
  match kind {
    Minimal => [fixture_observation("hello", Native, Passed, "hello world", 8)]
    CrossTarget =>
      [
        fixture_observation("hello", Native, Passed, "hello world", 8),
        fixture_observation("hello", Js, Passed, "hello world", 11),
        fixture_observation("hello", Wasm, Passed, "hello world", 15),
        fixture_observation("fmt", Native, Passed, "format ok", 5),
      ]
    ExpectedFailure =>
      [
        fixture_observation("invalid", Native, Failed, "invalid input", 3),
        fixture_observation("invalid", Js, Failed, "invalid input", 4),
      ]
    RestrictedTarget =>
      [
        fixture_observation("portable", Wasm, Passed, "hello world", 13),
        fixture_observation("portable", WasmGc, Passed, "hello world", 17),
      ]
  }
}

///|
pub fn scenario_fixture_matrix(kind : ScenarioFixtureKind) -> ScenarioMatrix {
  let manifest = scenario_fixture_manifest(kind)
  let targets = scenario_fixture_targets(kind)
  let observations = scenario_fixture_observations(kind)
  build_scenario_matrix(manifest, observations, targets)
}

///|
pub fn scenario_fixture_description(kind : ScenarioFixtureKind) -> String {
  match kind {
    Minimal => "one native case for a quick smoke check"
    CrossTarget => "portable examples observed on native, JavaScript and Wasm"
    ExpectedFailure =>
      "negative cases whose failure is intentional and recorded"
    RestrictedTarget => "host-independent cases for Wasm and Wasm GC"
  }
}

///|
pub fn scenario_fixture_catalog_markdown() -> String {
  let kinds = [Minimal, CrossTarget, ExpectedFailure, RestrictedTarget]
  let mut out = "| Fixture | Description | Targets | Passes |\n| --- | --- | --- | --- |\n"
  let mut index = 0
  while index < kinds.length() {
    let kind = kinds[index]
    let matrix = scenario_fixture_matrix(kind)
    out = out +
      "| `" +
      kind.name() +
      "` | " +
      scenario_fixture_description(kind)
    out = out +
      " | `" +
      join_target_names(scenario_fixture_targets(kind)) +
      "` | "
    out = out + bool_text(matrix.passes()) + " |\n"
    index += 1
  }
  out
}

///|
pub fn scenario_fixture_catalog_json() -> String {
  let kinds = [Minimal, CrossTarget, ExpectedFailure, RestrictedTarget]
  let mut out = "["
  let mut index = 0
  while index < kinds.length() {
    if index > 0 {
      out = out + ","
    }
    let kind = kinds[index]
    let matrix = scenario_fixture_matrix(kind)
    out = out + "{\"name\":\"" + kind.name() + "\","
    out = out +
      "\"targets\":\"" +
      join_target_names(scenario_fixture_targets(kind)) +
      "\","
    out = out + "\"passes\":" + bool_text(matrix.passes()) + "}"
    index += 1
  }
  out + "]"
}

///|
fn fixture_observation(
  id : String,
  target : ScenarioTarget,
  status : ObservationStatus,
  stdout : String,
  duration_ms : Int,
) -> ScenarioObservation {
  ScenarioObservation::{
    id,
    target,
    status,
    stdout,
    stderr: "",
    duration_ms,
    evidence_digest: scenario_evidence_digest(stdout, ""),
  }
}
