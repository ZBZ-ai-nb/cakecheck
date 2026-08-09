pub fn AuditReport::remediation_plan(self : AuditReport, limit : Int) -> String {
  let mut out = "# Remediation Plan\n\n"
  let mut emitted = 0
  let first = collect_remediation_by_severity(self, Error, limit, emitted)
  let (error_lines, after_errors) = first
  out = out + error_lines
  emitted = after_errors
  let second = collect_remediation_by_severity(self, Warning, limit, emitted)
  let (warning_lines, after_warnings) = second
  out = out + warning_lines
  emitted = after_warnings
  let third = collect_remediation_by_severity(self, Info, limit, emitted)
  let (info_lines, after_info) = third
  out = out + info_lines
  emitted = after_info
  if emitted == 0 {
    out + "- No remediation needed.\n"
  } else {
    out
  }
}

fn collect_remediation_by_severity(
  report : AuditReport,
  severity : Severity,
  limit : Int,
  emitted : Int
) -> (String, Int) {
  let mut out = ""
  let mut count = emitted
  let mut index = 0
  while index < report.checks.length() {
    if limit > 0 && count >= limit {
      return (out, count)
    }
    let item = report.checks[index]
    if item.severity == severity {
      out = out + remediation_line(count + 1, item)
      count += 1
    }
    index += 1
  }
  (out, count)
}

fn remediation_line(index : Int, item : AuditCheck) -> String {
  let mut line = "\{index}. [" + severity_name(item.severity) + "] "
  line = line + item.message + " (`" + item.code + "`)"
  if item.hint.length() > 0 {
    line = line + "\n   Hint: " + item.hint
  }
  line + "\n"
}

pub fn AuditReport::first_problem(self : AuditReport) -> AuditCheck? {
  let mut index = 0
  while index < self.checks.length() {
    if self.checks[index].severity == Error {
      return Some(self.checks[index])
    }
    index += 1
  }
  index = 0
  while index < self.checks.length() {
    if self.checks[index].severity == Warning {
      return Some(self.checks[index])
    }
    index += 1
  }
  index = 0
  while index < self.checks.length() {
    if self.checks[index].severity == Info {
      return Some(self.checks[index])
    }
    index += 1
  }
  None
}
