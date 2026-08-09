pub fn AuditReport::gate(self : AuditReport, profile : AuditProfile) -> GateResult {
  match profile {
    Quick => quick_gate(self)
    Release => release_gate(self)
    Hackathon => hackathon_gate(self)
  }
}

pub fn AuditReport::problem_count(self : AuditReport, category : Category) -> Int {
  let mut total = 0
  let mut index = 0
  while index < self.checks.length() {
    let item = self.checks[index]
    if item.category == category && item.severity != Pass {
      total += 1
    }
    index += 1
  }
  total
}

pub fn GateResult::summary(self : GateResult) -> String {
  let status = if self.passed { "passed" } else { "failed" }
  profile_name(self.profile) + ": " + status
}

pub fn AuditReport::pass_count(self : AuditReport, category : Category) -> Int {
  let mut total = 0
  let mut index = 0
  while index < self.checks.length() {
    let item = self.checks[index]
    if item.category == category && item.severity == Pass {
      total += 1
    }
    index += 1
  }
  total
}

fn quick_gate(report : AuditReport) -> GateResult {
  let required : Array[String] = [
    "moon-mod-has-name",
    "moon-mod-has-version",
    "moon-mod-has-license",
    "manifest-license",
  ]
  let passed = report.score.error_count == 0 && report_has_pass_codes(report, required)
  gate_result(
    Quick,
    passed,
    if passed {
      "quick profile passed"
    } else {
      "quick profile requires valid metadata and zero errors"
    },
    required,
  )
}

fn release_gate(report : AuditReport) -> GateResult {
  let required : Array[String] = [
    "repository-url",
    "readme-install",
    "readme-usage",
    "readme-example",
    "ci-moon-check",
    "ci-moon-build",
    "ci-moon-test",
    "license-recognized",
  ]
  let passed = report.score.error_count == 0 &&
               report.score.warning_count <= 2 &&
               report_has_pass_codes(report, required)
  gate_result(
    Release,
    passed,
    if passed {
      "release profile passed"
    } else {
      "release profile allows at most two warnings and requires README, CI and license coverage"
    },
    required,
  )
}

fn hackathon_gate(report : AuditReport) -> GateResult {
  let required : Array[String] = [
    "package-name-format",
    "version-semver",
    "repository-url",
    "readme-install",
    "readme-usage",
    "readme-example",
    "readme-check-command",
    "readme-build-command",
    "readme-test-command",
    "readme-dry-run-command",
    "ci-installs-moonbit",
    "ci-moon-check",
    "ci-moon-build",
    "ci-moon-test",
    "ci-moon-run",
    "license-recognized",
    "repo-public",
    "commit-count",
    "changelog-present",
    "mooncakes-published",
    "release-package-name",
  ]
  let passed = report.score.error_count == 0 &&
               report.score.warning_count == 0 &&
               report_has_pass_codes(report, required)
  gate_result(
    Hackathon,
    passed,
    if passed {
      "hackathon profile passed"
    } else {
      "hackathon profile requires zero errors, zero warnings and complete release evidence"
    },
    required,
  )
}

fn report_has_pass_codes(report : AuditReport, codes : Array[String]) -> Bool {
  let mut index = 0
  while index < codes.length() {
    if !report_has_pass_code(report, codes[index]) {
      return false
    }
    index += 1
  }
  true
}

fn report_has_pass_code(report : AuditReport, code : String) -> Bool {
  let mut index = 0
  while index < report.checks.length() {
    let item = report.checks[index]
    if item.code == code && item.severity == Pass {
      return true
    }
    index += 1
  }
  false
}

fn profile_name(profile : AuditProfile) -> String {
  match profile {
    Quick => "quick"
    Release => "release"
    Hackathon => "hackathon"
  }
}
