///|
test "parses matrix metadata and one scenario" {
  let manifest = parse_scenario_manifest(sample_manifest())
  assert_eq(manifest.name, "demo")
  assert_eq(manifest.version, "0.3.0")
  assert_eq(manifest.specs.length(), 2)
  assert_eq(manifest.issues.length(), 0)
  assert_eq(manifest.specs[0].target_names(), "native,js,wasm")
}

///|
test "quoted command and output remain intact" {
  let manifest = parse_scenario_manifest(sample_manifest())
  assert_eq(manifest.specs[0].command, "moon run examples/basic --target all")
  assert_eq(manifest.specs[0].expected_output, "hello world")
  assert_true(manifest.specs[0].has_tag("smoke"))
  assert_true(manifest.specs[0].has_tag("docs"))
}

///|
test "parser reports missing header and empty scenarios" {
  let manifest = parse_scenario_manifest(
    "scenario id=x command=run targets=native expected=success\n",
  )
  assert_true(manifest.issues.length() >= 1)
  assert_true(has_issue(manifest.issues, "matrix-header-missing"))
}

///|
test "parser rejects an unknown target" {
  let manifest = parse_scenario_manifest(
    "matrix name=x version=0.3.0\nscenario id=x command=run targets=quantum expected=success\n",
  )
  assert_true(has_issue(manifest.issues, "scenario-target-invalid"))
  assert_eq(manifest.specs.length(), 0)
}

///|
test "parser rejects an invalid timeout" {
  let manifest = parse_scenario_manifest(
    "matrix name=x version=0.3.0\nscenario id=x command=run targets=native expected=success timeout_ms=0\n",
  )
  assert_true(has_issue(manifest.issues, "scenario-timeout-invalid"))
}

///|
test "scenario target names and profiles are stable" {
  assert_eq(Native.name(), "native")
  assert_eq(Js.name(), "js")
  assert_eq(Wasm.name(), "wasm")
  assert_eq(WasmGc.name(), "wasm-gc")
  assert_true(target_profile(Native).supports_process)
  assert_false(target_profile(Wasm).supports_files)
  assert_true(target_profile_is_restricted(WasmGc))
}

///|
test "passing observations complete a required matrix" {
  let matrix = sample_matrix()
  assert_true(matrix.passes())
  assert_eq(matrix.required_count, 4)
  assert_eq(matrix.completed_count, 4)
  assert_eq(matrix.passed_count, 4)
  assert_eq(matrix.failed_count, 0)
  assert_eq(matrix.skipped_count, 0)
}

///|
test "matrix records missing required observations" {
  let manifest = parse_scenario_manifest(sample_manifest())
  let matrix = build_scenario_matrix(manifest, [], [Native, Js, Wasm])
  assert_false(matrix.passes())
  assert_true(has_issue(matrix.issues, "observation-missing"))
  assert_true(has_issue(matrix.issues, "target-coverage-incomplete"))
}

///|
test "matrix detects wrong output and duration" {
  let manifest = parse_scenario_manifest(sample_manifest())
  let observation = ScenarioObservation::{
    id: "hello",
    target: Native,
    status: Passed,
    stdout: "different",
    stderr: "",
    duration_ms: 999999,
    evidence_digest: "evidence-test",
  }
  let matrix = build_scenario_matrix(manifest, [observation], [Native])
  assert_false(matrix.passes())
  assert_eq(matrix.failed_count, 1)
}

///|
test "expected failures are valid observations" {
  let source = "matrix name=negative version=0.3.0\n" +
    "scenario id=reject title=reject command=run targets=native expected=failure " +
    "output=\"bad input\" timeout_ms=1000 required=true\n"
  let manifest = parse_scenario_manifest(source)
  let digest = scenario_evidence_digest("bad input", "")
  let observation = ScenarioObservation::{
    id: "reject",
    target: Native,
    status: Failed,
    stdout: "bad input",
    stderr: "",
    duration_ms: 2,
    evidence_digest: digest,
  }
  let matrix = build_scenario_matrix(manifest, [observation], [Native])
  assert_true(matrix.passes())
}

///|
test "duplicate scenario ids are rejected" {
  let source = "matrix name=x version=0.3.0\n" +
    "scenario id=s command=a targets=native expected=success\n" +
    "scenario id=s command=b targets=native expected=success\n"
  let manifest = parse_scenario_manifest(source)
  let matrix = build_scenario_matrix(manifest, [], [Native])
  assert_true(has_issue(matrix.issues, "scenario-id-duplicate"))
}

///|
test "duplicate observations are rejected" {
  let manifest = parse_scenario_manifest(sample_manifest())
  let digest = scenario_evidence_digest("hello world", "")
  let observation = sample_observation("hello", Native, digest)
  let matrix = build_scenario_matrix(manifest, [observation, observation], [
    Native,
  ])
  assert_true(has_issue(matrix.issues, "observation-duplicate"))
}

///|
test "evidence digest is deterministic and normalized" {
  let first = scenario_evidence_digest("hello\nworld", "")
  let second = scenario_evidence_digest("  hello\r\nworld  ", "")
  assert_eq(first, second)
  assert_true(digest_is_well_formed(first))
  assert_true(evidence_equal("a\n\nb", " a\r\nb "))
  assert_true(evidence_contains("hello world", "world"))
}

///|
test "matrix digest changes when evidence changes" {
  let matrix = sample_matrix()
  let before_digest = digest_for_matrix(matrix)
  let changed = ScenarioObservation::{
    id: "hello",
    target: Native,
    status: Passed,
    stdout: "changed",
    stderr: "",
    duration_ms: 1,
    evidence_digest: scenario_evidence_digest("changed", ""),
  }
  let manifest = parse_scenario_manifest(sample_manifest())
  let after = build_scenario_matrix(
    manifest,
    [
      changed,
      sample_observation(
        "hello",
        Js,
        scenario_evidence_digest("hello world", ""),
      ),
      sample_observation(
        "hello",
        Wasm,
        scenario_evidence_digest("hello world", ""),
      ),
      sample_observation(
        "lint",
        Native,
        scenario_evidence_digest("lint ok", ""),
      ),
    ],
    [Native, Js, Wasm],
  )
  assert_true(digest_for_matrix(after) != before_digest)
}

///|
test "query filters by target tag and status" {
  let matrix = sample_matrix()
  assert_eq(target_case_ids(matrix, Js).length(), 1)
  assert_eq(tag_case_ids(matrix, "smoke").length(), 3)
  assert_eq(required_case_ids(matrix).length(), 4)
  assert_eq(failed_case_ids(matrix).length(), 0)
  assert_eq(skipped_case_ids(matrix).length(), 0)
}

///|
test "stats summarize target cases" {
  let stats = scenario_stats(sample_matrix())
  assert_eq(stats.scenario_count, 2)
  assert_eq(stats.target_case_count, 4)
  assert_eq(stats.required_case_count, 4)
  assert_eq(stats.observed_case_count, 4)
  assert_eq(stats.passed_case_count, 4)
  assert_eq(stats.missing_case_count, 0)
}

///|
test "default policy accepts the sample matrix" {
  let matrix = apply_policy(sample_matrix(), default_matrix_policy())
  assert_true(matrix.passes())
  assert_true(policy_summary(default_matrix_policy()).length() > 0)
}

///|
test "strict policy reports missing wasm gc coverage" {
  let matrix = apply_policy(sample_matrix(), strict_matrix_policy())
  assert_false(matrix.passes())
  assert_true(has_issue(matrix.issues, "policy-target-not-covered"))
}

///|
test "run plan expands one scenario per target" {
  let steps = generate_run_plan(sample_matrix())
  assert_eq(steps.length(), 4)
  assert_eq(run_plan_required_count(steps), 4)
  assert_eq(run_plan_for_target(steps, Native).length(), 2)
  assert_true(run_plan_shell(steps).contains("hello"))
}

///|
test "reports contain matrix facts" {
  let matrix = sample_matrix()
  let markdown = matrix.to_markdown()
  let json = matrix.to_json()
  assert_true(markdown.contains("Target Coverage"))
  assert_true(markdown.contains("hello"))
  assert_true(json.contains("\"passes\":true"))
  assert_true(
    issue_json(scenario_issue("x", Notice, "s", "native", "m", "h")).contains(
      "notice",
    ),
  )
}

///|
test "history identifies regressions and recovery" {
  let before = sample_matrix()
  let after_manifest = parse_scenario_manifest(sample_manifest())
  let after_observations = [
    ScenarioObservation::{
      id: "hello",
      target: Native,
      status: Passed,
      stdout: "broken",
      stderr: "",
      duration_ms: 10,
      evidence_digest: scenario_evidence_digest("broken", ""),
    },
    sample_observation("hello", Js, scenario_evidence_digest("hello world", "")),
    sample_observation(
      "hello",
      Wasm,
      scenario_evidence_digest("hello world", ""),
    ),
    sample_observation("lint", Native, scenario_evidence_digest("lint ok", "")),
  ]
  let after = build_scenario_matrix(after_manifest, after_observations, [
    Native,
    Js,
    Wasm,
  ])
  let diff = diff_scenario_matrices(before, after)
  assert_true(diff.has_regressions())
  assert_true(diff.regressed_ids.length() >= 1)
  assert_true(diff.to_markdown().contains("Regressed"))
}

///|
test "observation records round trip through the text format" {
  let digest = scenario_evidence_digest("hello world", "")
  let original = sample_observation("hello", Native, digest)
  let encoded = observation_to_text(original)
  let parsed = parse_observation_records(encoded)
  assert_eq(parsed.issues.length(), 0)
  assert_eq(parsed.observations.length(), 1)
  assert_eq(observation_key(parsed.observations[0]), "hello@native")
  assert_eq(parsed.observations[0].stdout, "hello world")
}

///|
test "observation parser rejects malformed records" {
  let parsed = parse_observation_records(
    "observation id=x target=unknown status=wat duration_ms=nope\n",
  )
  assert_true(parsed.issues.length() >= 3)
  assert_eq(parsed.observations.length(), 0)
}

///|
test "observation JSON includes evidence fields" {
  let observation = sample_observation(
    "hello",
    Native,
    scenario_evidence_digest("hello world", ""),
  )
  let json = observation_to_json(observation)
  assert_true(json.contains("\"target\":\"native\""))
  assert_true(json.contains("\"digest\""))
  assert_true(observations_to_json([observation]).contains("stdout"))
}

///|
test "schedule groups cases by target and stays deterministic" {
  let schedule = build_schedule(sample_matrix())
  assert_true(schedule_is_deterministic(schedule))
  assert_eq(schedule.length(), 3)
  assert_eq(schedule_total_estimate(schedule), 40)
  assert_true(schedule_markdown(schedule).contains("Execution Schedule"))
  assert_true(schedule_json(schedule).contains("parallel_safe"))
}

///|
test "replay envelopes have unique stable keys" {
  let envelopes = build_replay_envelopes(sample_matrix())
  assert_eq(envelopes.length(), 4)
  assert_true(replay_envelopes_are_unique(envelopes))
  assert_true(replay_envelopes_digest(envelopes).length() > 0)
  assert_true(replay_envelopes_to_text(envelopes).contains("replay"))
  assert_true(replay_envelopes_to_json(envelopes).contains("replay_key"))
}

///|
test "replay redacts machine-specific path fragments" {
  let redacted = redact_machine_paths(
    "C:\\Users\\alice\\project /home/bob/project",
  )
  assert_true(redacted.contains("<user>/alice"))
  assert_true(redacted.contains("<home>/bob"))
  assert_false(redacted.contains("C:\\Users\\"))
}

///|
test "default reproduction contract is ready" {
  let contract = build_reproduction_contract(
    sample_matrix(),
    default_matrix_policy(),
  )
  assert_true(contract.is_ready())
  assert_eq(contract.replay_count, 4)
  assert_eq(contract.schedule_batch_count, 3)
  assert_true(contract.to_markdown().contains("matrix-passes"))
  assert_true(contract.to_json().contains("\"passes\":true"))
}

///|
test "strict reproduction contract exposes a failed invariant" {
  let contract = build_reproduction_contract(
    sample_matrix(),
    strict_matrix_policy(),
  )
  assert_false(contract.is_ready())
  match contract_invariant(contract, "policy-output") {
    None => assert_true(false)
    Some(invariant) => assert_false(invariant.passes)
  }
}

///|
test "target profile tables are machine readable" {
  let targets = [Native, Js, Wasm, WasmGc]
  assert_true(target_profiles_markdown(targets).contains("wasm-gc"))
  assert_true(target_profiles_json(targets).contains("\"process\":false"))
  assert_eq(target_profile_capabilities(Native).length(), 3)
  assert_eq(target_profile_capabilities(Wasm).length(), 0)
}

///|
test "policy catches success scenarios without output" {
  let source = "matrix name=x version=0.3.0\n" +
    "scenario id=x command=run targets=native expected=success required=true\n"
  let manifest = parse_scenario_manifest(source)
  let issues = policy_issues(manifest, default_matrix_policy())
  assert_true(has_issue(issues, "policy-output-missing"))
}

///|
test "metrics describe coverage and target balance" {
  let metrics = scenario_metrics(sample_matrix())
  assert_eq(metrics.target_case_count, 4)
  assert_eq(metrics.coverage_percent, 100)
  assert_eq(metrics.pass_percent, 100)
  assert_eq(metrics.total_duration_ms, 40)
  assert_eq(metrics_average_duration(metrics), 10)
  assert_eq(metrics_target_gap(metrics), 0)
  assert_true(metrics.ready())
  assert_true(metrics.to_markdown().contains("Target balance"))
  assert_true(metrics.to_json().contains("\"coverage_percent\":100"))
}

///|
test "fixture catalog provides distinct reproducible cases" {
  let kinds = [Minimal, CrossTarget, ExpectedFailure, RestrictedTarget]
  let mut index = 0
  while index < kinds.length() {
    let matrix = scenario_fixture_matrix(kinds[index])
    assert_true(matrix.issues_have_no_errors())
    assert_true(scenario_fixture_description(kinds[index]).length() > 0)
    index += 1
  }
  assert_true(scenario_fixture_catalog_markdown().contains("cross-target"))
  assert_true(scenario_fixture_catalog_json().contains("expected-failure"))
}

///|
test "risk report identifies restricted host assumptions" {
  let source = "matrix name=risk version=0.3.0\n" +
    "scenario id=bad command=\"read file native\" targets=wasm expected=success " +
    "output=\"ok\" timeout_ms=100 required=true\n"
  let matrix = build_scenario_matrix(parse_scenario_manifest(source), [], [Wasm])
  let report = analyze_scenario_risks(matrix)
  assert_true(report.high_count >= 1)
  assert_true(risk_has_code(report, "restricted-host-assumption"))
  assert_true(report.to_json().contains("restricted-host-assumption"))
}

///|
test "timeline records improvement and regression" {
  let good = sample_matrix()
  let empty = build_scenario_matrix(
    parse_scenario_manifest(sample_manifest()),
    [],
    [Native, Js, Wasm],
  )
  let timeline = build_matrix_timeline([empty, good, empty])
  assert_eq(timeline.snapshots.length(), 3)
  assert_eq(timeline.improved, 1)
  assert_eq(timeline.regressed, 1)
  assert_false(timeline.passes())
  assert_eq(timeline_ready_count(timeline), 1)
  assert_true(timeline.to_markdown().contains("Scenario Matrix Timeline"))
}

///|
test "fixture kinds expose stable names" {
  assert_eq(Minimal.name(), "minimal")
  assert_eq(CrossTarget.name(), "cross-target")
  assert_eq(ExpectedFailure.name(), "expected-failure")
  assert_eq(RestrictedTarget.name(), "restricted-target")
}

///|
fn sample_manifest() -> String {
  "matrix name=demo version=0.3.0\n" +
  "scenario id=hello title=hello command=\"moon run examples/basic --target all\" " +
  "targets=native,js,wasm expected=success output=\"hello world\" timeout_ms=30000 " +
  "required=true tags=smoke,docs\n" +
  "scenario id=lint title=lint command=\"moon fmt --check\" targets=native " +
  "expected=success output=\"lint ok\" timeout_ms=30000 required=true tags=quality\n"
}

///|
fn sample_observation(
  id : String,
  target : ScenarioTarget,
  digest : String,
) -> ScenarioObservation {
  ScenarioObservation::{
    id,
    target,
    status: Passed,
    stdout: if id == "lint" {
      "lint ok"
    } else {
      "hello world"
    },
    stderr: "",
    duration_ms: 10,
    evidence_digest: digest,
  }
}

///|
fn sample_matrix() -> ScenarioMatrix {
  let manifest = parse_scenario_manifest(sample_manifest())
  let hello_digest = scenario_evidence_digest("hello world", "")
  let lint_digest = scenario_evidence_digest("lint ok", "")
  build_scenario_matrix(
    manifest,
    [
      sample_observation("hello", Native, hello_digest),
      sample_observation("hello", Js, hello_digest),
      sample_observation("hello", Wasm, hello_digest),
      sample_observation("lint", Native, lint_digest),
    ],
    [Native, Js, Wasm],
  )
}

///|
fn has_issue(issues : Array[ScenarioIssue], code : String) -> Bool {
  let mut index = 0
  while index < issues.length() {
    if issues[index].code == code {
      return true
    }
    index += 1
  }
  false
}
