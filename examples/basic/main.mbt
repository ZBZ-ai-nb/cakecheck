///|
fn main {
  let source = "# A deterministic cross-target scenario manifest\n" +
    "matrix name=basic-demo version=0.3.0\n" +
    "scenario id=hello title=hello-world command=\"moon run examples/basic\" " +
    "targets=native,js,wasm expected=success output=\"scenario-ok\" " +
    "timeout_ms=30000 required=true tags=smoke,readme\n"
  let manifest = @audit.parse_scenario_manifest(source)
  let digest = @audit.scenario_evidence_digest("scenario-ok", "")
  let observations = [
    @audit.ScenarioObservation::{
      id: "hello",
      target: @audit.Native,
      status: @audit.Passed,
      stdout: "scenario-ok",
      stderr: "",
      duration_ms: 14,
      evidence_digest: digest,
    },
    @audit.ScenarioObservation::{
      id: "hello",
      target: @audit.Js,
      status: @audit.Passed,
      stdout: "scenario-ok",
      stderr: "",
      duration_ms: 19,
      evidence_digest: digest,
    },
    @audit.ScenarioObservation::{
      id: "hello",
      target: @audit.Wasm,
      status: @audit.Passed,
      stdout: "scenario-ok",
      stderr: "",
      duration_ms: 23,
      evidence_digest: digest,
    },
  ]
  let matrix = @audit.build_scenario_matrix(manifest, observations, [
    @audit.Native,
    @audit.Js,
    @audit.Wasm,
  ])
  let final_matrix = @audit.apply_policy(matrix, @audit.default_matrix_policy())
  println("CakeCheck Scenario Matrix")
  println(@audit.scenario_matrix_summary(final_matrix))
  println(final_matrix.to_markdown())
  println("matrix-digest=" + @audit.digest_for_matrix(final_matrix))
}
