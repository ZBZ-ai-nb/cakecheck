pub fn AuditReport::has_errors(self : AuditReport) -> Bool {
  self.score.error_count > 0
}

pub fn AuditReport::is_ready(self : AuditReport) -> Bool {
  self.score.error_count == 0 && self.score.warning_count == 0
}

pub fn AuditReport::summary(self : AuditReport) -> String {
  "package=\{self.package_name}, version=\{self.version}, readiness=\{self.score.readiness}, errors=\{self.score.error_count}, warnings=\{self.score.warning_count}"
}

pub fn AuditReport::to_markdown(self : AuditReport) -> String {
  let mut out = "# CakeCheck Audit Report\n\n"
  out = out + "- Package: `" + self.package_name + "`\n"
  out = out + "- Version: `" + self.version + "`\n"
  out = out + "- Readiness: " + self.score.readiness.to_string() + "/100\n"
  out = out + "- Errors: " + self.score.error_count.to_string() + "\n"
  out = out + "- Warnings: " + self.score.warning_count.to_string() + "\n\n"
  out = out + "| Severity | Category | Code | Message |\n"
  out = out + "| --- | --- | --- | --- |\n"
  let mut index = 0
  while index < self.checks.length() {
    let item = self.checks[index]
    out = out + "| " + severity_name(item.severity)
    out = out + " | " + category_name(item.category)
    out = out + " | `" + item.code + "`"
    out = out + " | " + item.message + " |\n"
    index += 1
  }
  out
}

pub fn AuditReport::to_json(self : AuditReport) -> String {
  let mut out = "{"
  out = out + "\"package\":\"" + json_escape(self.package_name) + "\","
  out = out + "\"version\":\"" + json_escape(self.version) + "\","
  out = out + "\"readiness\":" + self.score.readiness.to_string() + ","
  out = out + "\"errors\":" + self.score.error_count.to_string() + ","
  out = out + "\"warnings\":" + self.score.warning_count.to_string() + ","
  out = out + "\"checks\":["
  let mut index = 0
  while index < self.checks.length() {
    if index > 0 {
      out = out + ","
    }
    let item = self.checks[index]
    out = out + "{"
    out = out + "\"severity\":\"" + severity_name(item.severity) + "\","
    out = out + "\"category\":\"" + category_name(item.category) + "\","
    out = out + "\"code\":\"" + json_escape(item.code) + "\","
    out = out + "\"message\":\"" + json_escape(item.message) + "\""
    out = out + "}"
    index += 1
  }
  out + "]}"
}

fn json_escape(value : String) -> String {
  let mut out = ""
  let mut index = 0
  while index < value.length() {
    let code = code_at(value, index)
    if code == 34 {
      out = out + "\\\""
    } else if code == 92 {
      out = out + "\\\\"
    } else if code == 10 {
      out = out + "\\n"
    } else {
      out = out + slice(value, index, index + 1)
    }
    index += 1
  }
  out
}

