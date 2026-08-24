///|
pub fn parse_observation_records(text : String) -> ObservationParseResult {
  let observations : Array[ScenarioObservation] = []
  let issues : Array[ScenarioIssue] = []
  let lines = split_lines(text)
  let mut index = 0
  while index < lines.length() {
    let line_number = index + 1
    let line = trim_ascii(lines[index])
    if line.length() == 0 || starts_with(line, "#") {
      index += 1
      continue
    }
    let tokens = split_words_quoted(line)
    if tokens.length() == 0 || tokens[0] != "observation" {
      issues.push(
        scenario_issue(
          "observation-directive-invalid",
          Error,
          "",
          "line:" + line_number.to_string(),
          "observation record must start with the observation directive",
          "Use observation id=... target=... status=... .",
        ),
      )
      index += 1
      continue
    }
    let parsed = parse_observation_tokens(tokens, line_number)
    let mut issue_index = 0
    while issue_index < parsed.issues.length() {
      issues.push(parsed.issues[issue_index])
      issue_index += 1
    }
    match parsed.observation {
      None => ()
      Some(observation) => observations.push(observation)
    }
    index += 1
  }
  ObservationParseResult::{ observations, issues }
}

///|
pub fn observations_to_text(
  observations : Array[ScenarioObservation],
) -> String {
  let mut out = "# CakeCheck Scenario Matrix observations\n"
  let mut index = 0
  while index < observations.length() {
    out = out + observation_to_text(observations[index]) + "\n"
    index += 1
  }
  out
}

///|
pub fn observation_to_text(observation : ScenarioObservation) -> String {
  "observation id=" +
  observation.id +
  " target=" +
  observation.target.name() +
  " status=" +
  observation.status.name() +
  " duration_ms=" +
  observation.duration_ms.to_string() +
  " stdout=" +
  quote_field(observation.stdout) +
  " stderr=" +
  quote_field(observation.stderr) +
  " digest=" +
  quote_field(observation.evidence_digest)
}

///|
pub fn observations_to_json(
  observations : Array[ScenarioObservation],
) -> String {
  let mut out = "["
  let mut index = 0
  while index < observations.length() {
    if index > 0 {
      out = out + ","
    }
    out = out + observation_to_json(observations[index])
    index += 1
  }
  out + "]"
}

///|
pub fn observation_to_json(observation : ScenarioObservation) -> String {
  let mut out = "{\"id\":\"" + json_escape(observation.id) + "\","
  out = out + "\"target\":\"" + observation.target.name() + "\","
  out = out + "\"status\":\"" + observation.status.name() + "\","
  out = out + "\"duration_ms\":" + observation.duration_ms.to_string() + ","
  out = out + "\"stdout\":\"" + json_escape(observation.stdout) + "\","
  out = out + "\"stderr\":\"" + json_escape(observation.stderr) + "\","
  out + "\"digest\":\"" + json_escape(observation.evidence_digest) + "\"}"
}

///|
pub fn observation_key(observation : ScenarioObservation) -> String {
  observation.id + "@" + observation.target.name()
}

///|
pub fn observation_parse_summary(result : ObservationParseResult) -> String {
  "observations=" +
  result.observations.length().to_string() +
  ", issues=" +
  result.issues.length().to_string() +
  ", valid=" +
  bool_text(result.issues.length() == 0)
}

///|
fn parse_observation_tokens(
  tokens : Array[String],
  line_number : Int,
) -> ParsedObservation {
  let issues : Array[ScenarioIssue] = []
  let id = token_or_empty(tokens, "id")
  let target_text = token_or_empty(tokens, "target")
  let status_text = token_or_empty(tokens, "status")
  let duration_text = token_or_empty(tokens, "duration_ms")
  let stdout = token_or_default(tokens, "stdout", "")
  let stderr = token_or_default(tokens, "stderr", "")
  let digest = token_or_default(tokens, "digest", "")
  let target = match scenario_target(target_text) {
    None => {
      issues.push(
        scenario_issue(
          "observation-target-invalid",
          Error,
          id,
          target_text,
          "observation target is invalid",
          "Use native, js, wasm or wasm-gc.",
        ),
      )
      Native
    }
    Some(value) => value
  }
  let status = match parse_observation_status(status_text) {
    None => {
      issues.push(
        scenario_issue(
          "observation-status-invalid",
          Error,
          id,
          target_text,
          "observation status is invalid",
          "Use passed, failed or skipped.",
        ),
      )
      Skipped
    }
    Some(value) => value
  }
  let duration = parse_int(duration_text, -1)
  if id.length() == 0 {
    issues.push(
      scenario_issue(
        "observation-id-missing",
        Error,
        id,
        "line:" + line_number.to_string(),
        "observation id is missing",
        "Use the id from the corresponding scenario declaration.",
      ),
    )
  }
  if target_text.length() == 0 {
    issues.push(
      scenario_issue(
        "observation-target-missing",
        Error,
        id,
        "line:" + line_number.to_string(),
        "observation target is missing",
        "Declare the MoonBit target that produced the output.",
      ),
    )
  }
  if status_text.length() == 0 {
    issues.push(
      scenario_issue(
        "observation-status-missing",
        Error,
        id,
        target_text,
        "observation status is missing",
        "Record passed, failed or skipped.",
      ),
    )
  }
  if duration < 0 {
    issues.push(
      scenario_issue(
        "observation-duration-invalid",
        Error,
        id,
        target_text,
        "observation duration must be a non-negative integer",
        "Record elapsed milliseconds from the runner.",
      ),
    )
  }
  let observation = if has_error_issue(issues) {
    None
  } else {
    Some(ScenarioObservation::{
      id,
      target,
      status,
      stdout,
      stderr,
      duration_ms: duration,
      evidence_digest: digest,
    })
  }
  ParsedObservation::{ observation, issues }
}

///|
fn parse_observation_status(value : String) -> ObservationStatus? {
  match ascii_lower(trim_ascii(value)) {
    "passed" => Some(Passed)
    "pass" => Some(Passed)
    "failed" => Some(Failed)
    "fail" => Some(Failed)
    "skipped" => Some(Skipped)
    "skip" => Some(Skipped)
    _ => None
  }
}

///|
fn quote_field(value : String) -> String {
  let mut out = "\""
  let mut index = 0
  while index < value.length() {
    let code = code_at(value, index)
    if code == 34 || code == 92 {
      out = out + "\\"
    }
    out = out + slice(value, index, index + 1)
    index += 1
  }
  out + "\""
}
