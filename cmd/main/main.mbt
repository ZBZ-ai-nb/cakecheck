///|
fn main {
  let source = "matrix name=cli-smoke version=0.3.0\n" +
    "scenario id=cli-help title=cli-help command=\"moon run examples/basic\" " +
    "targets=native expected=success output=\"scenario-ok\" timeout_ms=30000 " +
    "required=true tags=cli\n"
  let manifest = @audit.parse_scenario_manifest(source)
  let digest = @audit.scenario_evidence_digest("scenario-ok", "")
  let observations = [
    @audit.ScenarioObservation::{
      id: "cli-help",
      target: @audit.Native,
      status: @audit.Passed,
      stdout: "scenario-ok",
      stderr: "",
      duration_ms: 12,
      evidence_digest: digest,
    },
  ]
  let matrix = @audit.build_scenario_matrix(manifest, observations, [
    @audit.Native,
  ])
  println(@audit.scenario_matrix_summary(matrix))
  println(@audit.run_plan_markdown(@audit.generate_run_plan(matrix)))
  println(matrix.to_json())
}
