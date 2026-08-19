///|
pub fn diff_reports(before : AuditReport, after : AuditReport) -> AuditDiff {
  let fixed : Array[String] = []
  let new_problems : Array[String] = []
  let mut before_index = 0
  while before_index < before.checks.length() {
    let item = before.checks[before_index]
    if item.severity != Pass && !report_has_problem(after, item.code) {
      if !string_array_contains(fixed, item.code) {
        fixed.push(item.code)
      }
    }
    before_index += 1
  }
  let mut after_index = 0
  while after_index < after.checks.length() {
    let item = after.checks[after_index]
    if item.severity != Pass && !report_has_problem(before, item.code) {
      if !string_array_contains(new_problems, item.code) {
        new_problems.push(item.code)
      }
    }
    after_index += 1
  }
  audit_diff(
    before.score.readiness,
    after.score.readiness,
    after.score.readiness - before.score.readiness,
    fixed,
    new_problems,
  )
}

///|
pub fn AuditDiff::summary(self : AuditDiff) -> String {
  "readiness \{self.before_readiness}->\{self.after_readiness} (delta=\{self.readiness_delta}), fixed=\{self.fixed_codes.length()}, new=\{self.new_problem_codes.length()}"
}

///|
pub fn AuditDiff::to_markdown(self : AuditDiff) -> String {
  let mut out = "# CakeCheck Diff\n\n"
  out = out + "- Before readiness: " + self.before_readiness.to_string() + "\n"
  out = out + "- After readiness: " + self.after_readiness.to_string() + "\n"
  out = out + "- Delta: " + self.readiness_delta.to_string() + "\n\n"
  out = out + "## Fixed\n\n"
  out = out + code_list(self.fixed_codes)
  out = out + "\n## New Problems\n\n"
  out = out + code_list(self.new_problem_codes)
  out
}

///|
fn report_has_problem(report : AuditReport, code : String) -> Bool {
  let mut index = 0
  while index < report.checks.length() {
    let item = report.checks[index]
    if item.code == code && item.severity != Pass {
      return true
    }
    index += 1
  }
  false
}

///|
fn string_array_contains(items : Array[String], value : String) -> Bool {
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
fn code_list(items : Array[String]) -> String {
  if items.length() == 0 {
    return "- None\n"
  }
  let mut out = ""
  let mut index = 0
  while index < items.length() {
    out = out + "- `" + items[index] + "`\n"
    index += 1
  }
  out
}
