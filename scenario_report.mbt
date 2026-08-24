///|
pub fn ScenarioMatrix::to_markdown(self : ScenarioMatrix) -> String {
  let mut out = "# Scenario Reproduction Matrix\n\n"
  out = out + "- Name: `" + self.name + "`\n"
  out = out + "- Version: `" + self.version + "`\n"
  out = out + "- Passes: " + bool_text(self.passes()) + "\n"
  out = out + "- Required cases: " + self.required_count.to_string() + "\n"
  out = out + "- Completed cases: " + self.completed_count.to_string() + "\n"
  out = out + "- Passed observations: " + self.passed_count.to_string() + "\n"
  out = out + "- Failed observations: " + self.failed_count.to_string() + "\n"
  out = out +
    "- Skipped observations: " +
    self.skipped_count.to_string() +
    "\n\n"
  out = out + "## Target Coverage\n\n"
  out = out + "| Target | Required | Observed | Passed | Complete |\n"
  out = out + "| --- | ---: | ---: | ---: | --- |\n"
  let mut coverage_index = 0
  while coverage_index < self.coverage.length() {
    let item = self.coverage[coverage_index]
    out = out + "| `" + item.target.name() + "` | "
    out = out + item.required_cases.to_string() + " | "
    out = out + item.observed_cases.to_string() + " | "
    out = out + item.passed_cases.to_string() + " | "
    out = out + bool_text(item.complete) + " |\n"
    coverage_index += 1
  }
  out = out + "\n## Scenarios\n\n"
  out = out + "| ID | Targets | Expected | Required | Command |\n"
  out = out + "| --- | --- | --- | --- | --- |\n"
  let mut spec_index = 0
  while spec_index < self.specs.length() {
    let spec = self.specs[spec_index]
    out = out + "| `" + spec.id + "` | " + spec.target_names()
    out = out + " | " + spec.expected.name() + " | "
    out = out + bool_text(spec.required) + " | `" + spec.command + "` |\n"
    spec_index += 1
  }
  out = out + "\n## Observations\n\n"
  out = out + "| ID | Target | Status | Duration | Evidence |\n"
  out = out + "| --- | --- | --- | ---: | --- |\n"
  let mut observation_index = 0
  while observation_index < self.observations.length() {
    let item = self.observations[observation_index]
    out = out + "| `" + item.id + "` | `" + item.target.name() + "` | "
    out = out + item.status.name() + " | " + item.duration_ms.to_string()
    out = out + " ms | `" + item.evidence_digest + "` |\n"
    observation_index += 1
  }
  out = out + "\n## Issues\n\n"
  if self.issues.length() == 0 {
    out = out + "No issues.\n"
  } else {
    out = out + "| Severity | Code | Scenario | Target | Message |\n"
    out = out + "| --- | --- | --- | --- | --- |\n"
    let mut issue_index = 0
    while issue_index < self.issues.length() {
      let issue = self.issues[issue_index]
      out = out + "| " + issue.severity.name() + " | `" + issue.code + "` | `"
      out = out + issue.scenario_id + "` | `" + issue.target + "` | "
      out = out + issue.message + " |\n"
      issue_index += 1
    }
  }
  out
}

///|
pub fn ScenarioMatrix::to_json(self : ScenarioMatrix) -> String {
  let mut out = "{"
  out = out + "\"name\":\"" + json_escape(self.name) + "\","
  out = out + "\"version\":\"" + json_escape(self.version) + "\","
  out = out + "\"passes\":" + bool_text(self.passes()) + ","
  out = out + "\"required\":" + self.required_count.to_string() + ","
  out = out + "\"completed\":" + self.completed_count.to_string() + ","
  out = out + "\"passed\":" + self.passed_count.to_string() + ","
  out = out + "\"failed\":" + self.failed_count.to_string() + ","
  out = out + "\"skipped\":" + self.skipped_count.to_string() + ","
  out = out + "\"coverage\":["
  let mut index = 0
  while index < self.coverage.length() {
    if index > 0 {
      out = out + ","
    }
    let item = self.coverage[index]
    out = out + "{\"target\":\"" + item.target.name() + "\","
    out = out + "\"required\":" + item.required_cases.to_string() + ","
    out = out + "\"observed\":" + item.observed_cases.to_string() + ","
    out = out + "\"passed\":" + item.passed_cases.to_string() + ","
    out = out + "\"complete\":" + bool_text(item.complete) + "}"
    index += 1
  }
  out = out + "],\"issues\":["
  index = 0
  while index < self.issues.length() {
    if index > 0 {
      out = out + ","
    }
    let issue = self.issues[index]
    out = out + "{\"code\":\"" + json_escape(issue.code) + "\","
    out = out + "\"severity\":\"" + issue.severity.name() + "\","
    out = out + "\"scenario\":\"" + json_escape(issue.scenario_id) + "\","
    out = out + "\"target\":\"" + json_escape(issue.target) + "\","
    out = out + "\"message\":\"" + json_escape(issue.message) + "\"}"
    index += 1
  }
  out + "]}"
}

///|
pub fn ScenarioManifest::to_markdown(self : ScenarioManifest) -> String {
  let mut out = "# Scenario Manifest\n\n"
  out = out + "- Name: `" + self.name + "`\n"
  out = out + "- Version: `" + self.version + "`\n"
  out = out + "- Scenarios: " + self.specs.length().to_string() + "\n\n"
  out = out + "| ID | Title | Targets | Expected | Timeout | Required |\n"
  out = out + "| --- | --- | --- | --- | ---: | --- |\n"
  let mut index = 0
  while index < self.specs.length() {
    let spec = self.specs[index]
    out = out + "| `" + spec.id + "` | " + spec.title + " | "
    out = out + spec.target_names() + " | " + spec.expected.name() + " | "
    out = out +
      spec.timeout_ms.to_string() +
      " ms | " +
      bool_text(spec.required) +
      " |\n"
    index += 1
  }
  if self.issues.length() > 0 {
    out = out + "\n## Parse Issues\n\n"
    index = 0
    while index < self.issues.length() {
      let issue = self.issues[index]
      out = out + "- **" + issue.code + "**: " + issue.message + "\n"
      index += 1
    }
  }
  out
}

///|
pub fn issue_json(issue : ScenarioIssue) -> String {
  "{\"code\":\"" +
  json_escape(issue.code) +
  "\",\"severity\":\"" +
  issue.severity.name() +
  "\",\"scenario\":\"" +
  json_escape(issue.scenario_id) +
  "\",\"target\":\"" +
  json_escape(issue.target) +
  "\",\"message\":\"" +
  json_escape(issue.message) +
  "\",\"hint\":\"" +
  json_escape(issue.hint) +
  "\"}"
}
