///|
pub fn analyze_scenario_risks(matrix : ScenarioMatrix) -> ScenarioRiskReport {
  let findings : Array[ScenarioRiskFinding] = []
  let mut low_count = 0
  let mut medium_count = 0
  let mut high_count = 0
  let mut spec_index = 0
  while spec_index < matrix.specs.length() {
    let spec = matrix.specs[spec_index]
    let mut target_index = 0
    while target_index < spec.targets.length() {
      let target = spec.targets[target_index]
      let profile = target_profile(target)
      if target_profile_is_restricted(target) &&
        (
          contains(ascii_lower(spec.command), "file") ||
          contains(ascii_lower(spec.command), "process") ||
          contains(ascii_lower(spec.command), "native")
        ) {
        findings.push(ScenarioRiskFinding::{
          scenario_id: spec.id,
          target,
          level: High,
          code: "restricted-host-assumption",
          message: "restricted target command appears to depend on a host capability",
          hint: "Split the host-bound case from the portable target or provide a Wasm-safe fixture.",
        })
        high_count += 1
      } else if spec.expected == Success && spec.expected_output.length() == 0 {
        findings.push(ScenarioRiskFinding::{
          scenario_id: spec.id,
          target,
          level: Medium,
          code: "success-without-output",
          message: "success scenario has no stable output fragment",
          hint: "Declare a short output fragment so a green observation is reviewable.",
        })
        medium_count += 1
      } else if spec.timeout_ms > 120000 {
        findings.push(ScenarioRiskFinding::{
          scenario_id: spec.id,
          target,
          level: Medium,
          code: "unbounded-runtime",
          message: "scenario timeout is too large for a quick reproduction matrix",
          hint: "Use a smaller fixture or document why the longer timeout is necessary.",
        })
        medium_count += 1
      } else if !profile.supports_process &&
        contains(ascii_lower(spec.command), "shell") {
        findings.push(ScenarioRiskFinding::{
          scenario_id: spec.id,
          target,
          level: Medium,
          code: "process-assumption",
          message: "command text suggests a process dependency on a non-process target",
          hint: "Keep shell orchestration outside the portable scenario itself.",
        })
        medium_count += 1
      } else {
        low_count += 1
      }
      target_index += 1
    }
    spec_index += 1
  }
  ScenarioRiskReport::{
    findings,
    low_count,
    medium_count,
    high_count,
    passes: high_count == 0,
  }
}

///|
pub fn ScenarioRiskReport::summary(self : ScenarioRiskReport) -> String {
  "risk-passes=" +
  bool_text(self.passes) +
  ", low=" +
  self.low_count.to_string() +
  ", medium=" +
  self.medium_count.to_string() +
  ", high=" +
  self.high_count.to_string()
}

///|
pub fn ScenarioRiskReport::to_markdown(self : ScenarioRiskReport) -> String {
  let mut out = "# Scenario Portability Risk Report\n\n"
  out = out + "- Passes: " + bool_text(self.passes) + "\n"
  out = out + "- Low: " + self.low_count.to_string() + "\n"
  out = out + "- Medium: " + self.medium_count.to_string() + "\n"
  out = out + "- High: " + self.high_count.to_string() + "\n\n"
  out = out + "| Level | Code | Scenario | Target | Finding | Hint |\n"
  out = out + "| --- | --- | --- | --- | --- | --- |\n"
  let mut index = 0
  while index < self.findings.length() {
    let finding = self.findings[index]
    out = out + "| " + finding.level.name() + " | `" + finding.code + "` | `"
    out = out + finding.scenario_id + "` | `" + finding.target.name() + "` | "
    out = out + finding.message + " | " + finding.hint + " |\n"
    index += 1
  }
  out
}

///|
pub fn ScenarioRiskReport::to_json(self : ScenarioRiskReport) -> String {
  let mut out = "{\"passes\":" + bool_text(self.passes) + ","
  out = out + "\"low\":" + self.low_count.to_string() + ","
  out = out + "\"medium\":" + self.medium_count.to_string() + ","
  out = out + "\"high\":" + self.high_count.to_string() + ",\"findings\":["
  let mut index = 0
  while index < self.findings.length() {
    if index > 0 {
      out = out + ","
    }
    let finding = self.findings[index]
    out = out + "{\"level\":\"" + finding.level.name() + "\","
    out = out + "\"code\":\"" + finding.code + "\","
    out = out + "\"scenario\":\"" + json_escape(finding.scenario_id) + "\","
    out = out + "\"target\":\"" + finding.target.name() + "\","
    out = out + "\"message\":\"" + json_escape(finding.message) + "\"}"
    index += 1
  }
  out + "]}"
}

///|
pub fn risk_findings_for(
  report : ScenarioRiskReport,
  level : ScenarioRiskLevel,
) -> Array[ScenarioRiskFinding] {
  let result : Array[ScenarioRiskFinding] = []
  let mut index = 0
  while index < report.findings.length() {
    if report.findings[index].level == level {
      result.push(report.findings[index])
    }
    index += 1
  }
  result
}

///|
pub fn risk_has_code(report : ScenarioRiskReport, code : String) -> Bool {
  let mut index = 0
  while index < report.findings.length() {
    if report.findings[index].code == code {
      return true
    }
    index += 1
  }
  false
}
