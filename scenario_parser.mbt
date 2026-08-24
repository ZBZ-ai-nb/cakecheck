///|
pub fn parse_scenario_manifest(text : String) -> ScenarioManifest {
  let mut name = ""
  let mut version = ""
  let specs : Array[ScenarioSpec] = []
  let issues : Array[ScenarioIssue] = []
  let lines = split_lines(text)
  let mut header_seen = false
  let mut line_index = 0
  while line_index < lines.length() {
    let line_number = line_index + 1
    let line = trim_ascii(lines[line_index])
    if line.length() == 0 || starts_with(line, "#") {
      line_index += 1
      continue
    }
    let tokens = split_words_quoted(line)
    if tokens.length() == 0 {
      line_index += 1
      continue
    }
    match tokens[0] {
      "matrix" => {
        header_seen = true
        match token_value(tokens, "name") {
          Some(value) => name = value
          None =>
            issues.push(
              parser_issue(
                "matrix-name-missing", line_number, "matrix name is required",
              ),
            )
        }
        match token_value(tokens, "version") {
          Some(value) => version = value
          None =>
            issues.push(
              parser_issue(
                "matrix-version-missing", line_number, "matrix version is required",
              ),
            )
        }
      }
      "scenario" => {
        let parsed = parse_scenario_tokens(tokens, line_number)
        let mut issue_index = 0
        while issue_index < parsed.issues.length() {
          issues.push(parsed.issues[issue_index])
          issue_index += 1
        }
        match parsed.spec {
          None => ()
          Some(spec) => specs.push(spec)
        }
      }
      _ =>
        issues.push(
          parser_issue(
            "unknown-directive", line_number, "only matrix and scenario directives are supported",
          ),
        )
    }
    line_index += 1
  }
  if !header_seen {
    issues.push(
      scenario_issue(
        "matrix-header-missing",
        Error,
        "",
        "",
        "scenario manifest has no matrix header",
        "Add: matrix name=examples version=0.3.0",
      ),
    )
  }
  if specs.length() == 0 {
    issues.push(
      scenario_issue(
        "scenario-empty",
        Error,
        "",
        "",
        "scenario manifest contains no valid scenarios",
        "Add at least one scenario line with an id, command and target.",
      ),
    )
  }
  ScenarioManifest::{ name, version, specs, issues }
}

///|
fn parse_scenario_tokens(
  tokens : Array[String],
  line_number : Int,
) -> ParsedScenario {
  let issues : Array[ScenarioIssue] = []
  let line_label = "line:" + line_number.to_string()
  let id = token_or_empty(tokens, "id")
  let title = token_or_default(tokens, "title", id)
  let command = token_or_empty(tokens, "command")
  let expected_value = token_or_empty(tokens, "expected")
  let output = token_or_default(tokens, "output", "")
  let timeout = parse_int(token_or_default(tokens, "timeout_ms", "30000"), -1)
  let required = parse_bool(token_or_default(tokens, "required", "true"), false)
  let tags = split_csv(token_or_default(tokens, "tags", ""))
  let targets : Array[ScenarioTarget] = []
  let targets_valid = match token_value(tokens, "targets") {
    None => {
      issues.push(
        scenario_issue(
          "scenario-targets-missing",
          Error,
          id,
          line_label,
          "scenario has no target list",
          "Use targets=native or targets=native,js.",
        ),
      )
      false
    }
    Some(value) => {
      let names = split_csv(value)
      let mut valid = names.length() > 0
      let mut index = 0
      while index < names.length() {
        match scenario_target(names[index]) {
          None => {
            valid = false
            issues.push(
              scenario_issue(
                "scenario-target-invalid",
                Error,
                id,
                names[index],
                "scenario target is not a supported MoonBit target",
                "Use native, js, wasm or wasm-gc.",
              ),
            )
          }
          Some(target) =>
            if contains_target(targets, target) {
              valid = false
              issues.push(
                scenario_issue(
                  "scenario-target-duplicate",
                  Warning,
                  id,
                  target.name(),
                  "scenario lists the same target more than once",
                  "Keep one entry per target.",
                ),
              )
            } else {
              targets.push(target)
            }
        }
        index += 1
      }
      valid
    }
  }
  if id.length() == 0 || !is_valid_identifier(id) {
    issues.push(
      scenario_issue(
        "scenario-id-invalid",
        Error,
        id,
        line_label,
        "scenario id must be a non-empty identifier",
        "Use lowercase letters, digits, hyphens or underscores.",
      ),
    )
  }
  if command.length() == 0 {
    issues.push(
      scenario_issue(
        "scenario-command-missing",
        Error,
        id,
        line_label,
        "scenario command is empty",
        "Declare the exact command a maintainer can run to reproduce the case.",
      ),
    )
  }
  let expected = match expected_status(expected_value) {
    None => {
      issues.push(
        scenario_issue(
          "scenario-expected-invalid",
          Error,
          id,
          line_label,
          "scenario expected value must be success or failure",
          "Use expected=success or expected=failure.",
        ),
      )
      Success
    }
    Some(value) => value
  }
  if expected_value.length() == 0 {
    issues.push(
      scenario_issue(
        "scenario-expected-missing",
        Error,
        id,
        line_label,
        "scenario expected value is missing",
        "Declare whether the command should succeed or fail.",
      ),
    )
  }
  if timeout <= 0 {
    issues.push(
      scenario_issue(
        "scenario-timeout-invalid",
        Error,
        id,
        line_label,
        "scenario timeout must be positive milliseconds",
        "Use a bounded timeout such as timeout_ms=30000.",
      ),
    )
  }
  if !targets_valid {
    issues.push(
      scenario_issue(
        "scenario-targets-invalid",
        Error,
        id,
        line_label,
        "scenario target list is invalid",
        "Fix the target list before producing a matrix.",
      ),
    )
  }
  let has_blocking_issue = has_error_issue(issues)
  let spec : ScenarioSpec? = if has_blocking_issue {
    None
  } else {
    Some(ScenarioSpec::{
      id,
      title,
      command,
      targets,
      expected,
      expected_output: output,
      timeout_ms: timeout,
      required,
      tags,
    })
  }
  ParsedScenario::{ spec, issues }
}

///|
fn token_or_empty(tokens : Array[String], key : String) -> String {
  match token_value(tokens, key) {
    None => ""
    Some(value) => value
  }
}

///|
fn token_or_default(
  tokens : Array[String],
  key : String,
  fallback : String,
) -> String {
  match token_value(tokens, key) {
    None => fallback
    Some(value) => value
  }
}

///|
fn parser_issue(
  code : String,
  line_number : Int,
  message : String,
) -> ScenarioIssue {
  scenario_issue(
    code,
    Error,
    "",
    "line:" + line_number.to_string(),
    message,
    "Check the matrix header syntax and required fields.",
  )
}

///|
fn has_error_issue(items : Array[ScenarioIssue]) -> Bool {
  let mut index = 0
  while index < items.length() {
    if items[index].severity == Error {
      return true
    }
    index += 1
  }
  false
}
