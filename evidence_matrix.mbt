///|
pub fn build_acceptance_evidence(input : AuditInput) -> EvidenceMatrix {
  evidence_from_report(input, audit_project(input))
}

///|
pub fn evidence_from_report(
  input : AuditInput,
  report : AuditReport,
) -> EvidenceMatrix {
  let manifest = parse_manifest(input.moon_mod)
  let readme = analyze_readme(input.readme)
  let workflow = analyze_workflow(input.ci)
  let license = analyze_license(input.license_text)
  let namespace_data = namespace_from_manifest(manifest)
  let items : Array[EvidenceItem] = []
  push_evidence(
    items,
    "moonbit-project",
    "Valid MoonBit project metadata",
    !report.has_errors() || manifest.has("name"),
    "moon.mod",
  )
  push_evidence(
    items,
    "package-name",
    "Mooncakes owner/package namespace",
    namespace_data.valid,
    "moon.mod name",
  )
  push_evidence(
    items,
    "version",
    "Semantic release version",
    parse_semver(report.version).valid,
    "moon.mod version",
  )
  push_evidence(
    items,
    "repository-url",
    "GitHub repository URL",
    report_has_code(report, "repository-url", Pass),
    "moon.mod repository",
  )
  push_evidence(
    items,
    "readme-present",
    "README exists",
    report_has_code(report, "readme-present", Pass),
    "README.md",
  )
  push_evidence(
    items,
    "readme-complete",
    "README covers install, usage, example and validation",
    readme.coverage_score() >= 80,
    "README.md",
  )
  push_evidence(
    items,
    "readme-commands",
    "README includes check/build/test/publish commands",
    readme.command_count >= 3,
    "README.md",
  )
  push_evidence(
    items,
    "example",
    "Runnable example is documented",
    report_has_code(report, "readme-example", Pass) || workflow.has_run,
    "README or CI",
  )
  push_evidence(
    items,
    "ci-present",
    "GitHub Actions workflow exists",
    report_has_code(report, "ci-present", Pass),
    ".github/workflows",
  )
  push_evidence(
    items,
    "ci-check",
    "CI runs moon check",
    workflow.has_check,
    ".github/workflows",
  )
  push_evidence(
    items,
    "ci-build",
    "CI runs moon build",
    workflow.has_build,
    ".github/workflows",
  )
  push_evidence(
    items,
    "ci-test",
    "CI runs moon test",
    workflow.has_test,
    ".github/workflows",
  )
  push_evidence(
    items,
    "ci-run",
    "CI runs an example",
    workflow.has_run,
    ".github/workflows",
  )
  push_evidence(
    items,
    "license",
    "OSI approved license is present",
    license.is_publishable(),
    "LICENSE",
  )
  push_evidence(
    items,
    "public-repo",
    "Repository is public",
    input.repository_public,
    "GitHub settings",
  )
  push_evidence(
    items,
    "commit-history",
    "Development history is traceable",
    input.commit_count >= 5,
    "git log",
  )
  push_evidence(
    items,
    "changelog",
    "Change log is present",
    trim_ascii(input.changelog).length() > 0,
    "CHANGELOG.md",
  )
  push_evidence(
    items,
    "mooncakes",
    "Package is published to mooncakes.io",
    input.package_published,
    "mooncakes.io",
  )
  evidence_matrix(
    items,
    evidence_present_count(items),
    evidence_missing_count(items),
  )
}

///|
pub fn EvidenceItem::status_text(self : EvidenceItem) -> String {
  if self.present {
    "present"
  } else {
    "missing"
  }
}

///|
pub fn EvidenceItem::markdown_row(self : EvidenceItem) -> String {
  "| `" +
  self.code +
  "` | " +
  self.label +
  " | " +
  self.status_text() +
  " | " +
  self.source +
  " |\n"
}

///|
pub fn EvidenceMatrix::coverage_percent(self : EvidenceMatrix) -> Int {
  let total = self.items.length()
  if total == 0 {
    0
  } else {
    self.present_count * 100 / total
  }
}

///|
pub fn EvidenceMatrix::is_complete(self : EvidenceMatrix) -> Bool {
  self.missing_count == 0 && self.items.length() > 0
}

///|
pub fn EvidenceMatrix::acceptance_label(self : EvidenceMatrix) -> String {
  if self.is_complete() {
    "complete"
  } else if self.coverage_percent() >= 85 {
    "nearly-complete"
  } else if self.coverage_percent() >= 65 {
    "partial"
  } else {
    "insufficient"
  }
}

///|
pub fn EvidenceMatrix::summary(self : EvidenceMatrix) -> String {
  "evidence=\{self.present_count}/\{self.items.length()}, missing=\{self.missing_count}, label=\{self.acceptance_label()}"
}

///|
pub fn EvidenceMatrix::missing_items(
  self : EvidenceMatrix,
) -> Array[EvidenceItem] {
  let missing : Array[EvidenceItem] = []
  let mut index = 0
  while index < self.items.length() {
    if !self.items[index].present {
      missing.push(self.items[index])
    }
    index += 1
  }
  missing
}

///|
pub fn EvidenceMatrix::present_items(
  self : EvidenceMatrix,
) -> Array[EvidenceItem] {
  let present : Array[EvidenceItem] = []
  let mut index = 0
  while index < self.items.length() {
    if self.items[index].present {
      present.push(self.items[index])
    }
    index += 1
  }
  present
}

///|
pub fn EvidenceMatrix::missing_codes(self : EvidenceMatrix) -> Array[String] {
  let codes : Array[String] = []
  let missing = self.missing_items()
  let mut index = 0
  while index < missing.length() {
    codes.push(missing[index].code)
    index += 1
  }
  codes
}

///|
pub fn EvidenceMatrix::has(self : EvidenceMatrix, code : String) -> Bool {
  let mut index = 0
  while index < self.items.length() {
    if self.items[index].code == code && self.items[index].present {
      return true
    }
    index += 1
  }
  false
}

///|
pub fn EvidenceMatrix::missing_label_text(self : EvidenceMatrix) -> String {
  let missing = self.missing_items()
  if missing.length() == 0 {
    return "none"
  }
  let mut out = ""
  let mut index = 0
  while index < missing.length() {
    if index > 0 {
      out = out + ", "
    }
    out = out + missing[index].label
    index += 1
  }
  out
}

///|
pub fn EvidenceMatrix::to_markdown(self : EvidenceMatrix) -> String {
  let mut out = "## Acceptance Evidence\n\n"
  out = out + "- Coverage: " + self.coverage_percent().to_string() + "%\n"
  out = out + "- Present: " + self.present_count.to_string() + "\n"
  out = out + "- Missing: " + self.missing_count.to_string() + "\n"
  out = out + "- Label: " + self.acceptance_label() + "\n\n"
  out = out +
    "| Code | Evidence | Status | Source |\n| --- | --- | --- | --- |\n"
  let mut index = 0
  while index < self.items.length() {
    out = out + self.items[index].markdown_row()
    index += 1
  }
  out
}

///|
pub fn EvidenceMatrix::to_json(self : EvidenceMatrix) -> String {
  let mut out = "{"
  out = out + "\"coverage\":" + self.coverage_percent().to_string() + ","
  out = out + "\"present\":" + self.present_count.to_string() + ","
  out = out + "\"missing\":" + self.missing_count.to_string() + ","
  out = out + "\"items\":["
  let mut index = 0
  while index < self.items.length() {
    if index > 0 {
      out = out + ","
    }
    let item = self.items[index]
    out = out + "{"
    out = out + "\"code\":\"" + json_escape(item.code) + "\","
    out = out + "\"label\":\"" + json_escape(item.label) + "\","
    out = out + "\"present\":" + bool_json(item.present) + ","
    out = out + "\"source\":\"" + json_escape(item.source) + "\""
    out = out + "}"
    index += 1
  }
  out + "]}"
}

///|
pub fn compare_evidence(
  before : EvidenceMatrix,
  after : EvidenceMatrix,
) -> AuditDiff {
  let fixed : Array[String] = []
  let new_problems : Array[String] = []
  let mut index = 0
  while index < after.items.length() {
    let item = after.items[index]
    let was_present = before.has(item.code)
    if item.present && !was_present {
      fixed.push(item.code)
    }
    if !item.present && before.has(item.code) {
      new_problems.push(item.code)
    }
    index += 1
  }
  audit_diff(
    before.coverage_percent(),
    after.coverage_percent(),
    after.coverage_percent() - before.coverage_percent(),
    fixed,
    new_problems,
  )
}

///|
pub fn evidence_markdown_summary(input : AuditInput) -> String {
  build_acceptance_evidence(input).to_markdown()
}

///|
fn push_evidence(
  items : Array[EvidenceItem],
  code : String,
  label : String,
  present : Bool,
  source : String,
) -> Unit {
  items.push(evidence_item(code, label, present, source))
}

///|
fn evidence_present_count(items : Array[EvidenceItem]) -> Int {
  let mut count = 0
  let mut index = 0
  while index < items.length() {
    if items[index].present {
      count += 1
    }
    index += 1
  }
  count
}

///|
fn evidence_missing_count(items : Array[EvidenceItem]) -> Int {
  items.length() - evidence_present_count(items)
}

///|
fn report_has_code(
  report : AuditReport,
  code : String,
  severity : Severity,
) -> Bool {
  let mut index = 0
  while index < report.checks.length() {
    let item = report.checks[index]
    if item.code == code && item.severity == severity {
      return true
    }
    index += 1
  }
  false
}

///|
fn bool_json(value : Bool) -> String {
  if value {
    "true"
  } else {
    "false"
  }
}
