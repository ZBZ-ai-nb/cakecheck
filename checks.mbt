pub fn audit_project(input : AuditInput) -> AuditReport {
  let manifest = parse_manifest(input.moon_mod)
  let checks : Array[AuditCheck] = []
  audit_manifest(checks, manifest)
  audit_readme(checks, input.readme, manifest)
  audit_ci(checks, input.ci)
  audit_license(checks, input.license_text)
  audit_repository(checks, input)
  audit_release(checks, input, manifest)
  let package_name = manifest.package_name()
  let version = manifest.version()
  audit_report(package_name, version, checks, compute_score(checks))
}

fn audit_manifest(checks : Array[AuditCheck], manifest : ManifestInfo) -> Unit {
  require_field(checks, manifest, "name")
  require_field(checks, manifest, "version")
  require_field(checks, manifest, "readme")
  require_field(checks, manifest, "repository")
  require_field(checks, manifest, "license")
  require_field(checks, manifest, "description")
  require_field(checks, manifest, "preferred_target")
  let mut malformed_index = 0
  while malformed_index < manifest.malformed_lines.length() {
    checks.push(check(
      Manifest,
      Error,
      "moon-mod-malformed-line",
      "moon.mod line \{manifest.malformed_lines[malformed_index]} is not a key-value field",
      "Use key = value syntax for MoonBit package metadata.",
    ))
    malformed_index += 1
  }
  let mut duplicate_index = 0
  while duplicate_index < manifest.duplicates.length() {
    checks.push(check(
      Manifest,
      Warning,
      "moon-mod-duplicate-field",
      "moon.mod has duplicate field '\{manifest.duplicates[duplicate_index]}'",
      "Keep one source of truth for each package metadata field.",
    ))
    duplicate_index += 1
  }
  match manifest.get("name") {
    None => ()
    Some(name) => {
      if valid_package_name(name) {
        checks.push(check(Manifest, Pass, "package-name-format", "package name uses owner/name format", ""))
      } else {
        checks.push(check(
          Manifest,
          Error,
          "package-name-format",
          "package name must use owner/package format",
          "Example: your-owner/cakecheck.",
        ))
      }
      if has_placeholder(name) {
        checks.push(check(
          Manifest,
          Warning,
          "package-name-placeholder",
          "package name still contains a placeholder",
          "Replace owner and package placeholders before publishing.",
        ))
      }
    }
  }
  match manifest.get("version") {
    None => ()
    Some(version) => {
      if valid_semver(version) {
        checks.push(check(Manifest, Pass, "version-semver", "version uses x.y.z semver shape", ""))
      } else {
        checks.push(check(
          Manifest,
          Error,
          "version-semver",
          "version is not in x.y.z semver shape",
          "Use a release version such as 0.1.0.",
        ))
      }
    }
  }
  match manifest.get("repository") {
    None => ()
    Some(repository) => {
      if starts_with(repository, "https://github.com/") && ends_with(repository, ".git") {
        checks.push(check(Manifest, Pass, "repository-url", "repository points to a GitHub .git URL", ""))
      } else {
        checks.push(check(
          Manifest,
          Warning,
          "repository-url",
          "repository should point to a GitHub .git URL",
          "Use https://github.com/<user>/<repo>.git.",
        ))
      }
    }
  }
  match manifest.get("license") {
    None => ()
    Some(license) => {
      if is_known_osi_license(license) {
        checks.push(check(Manifest, Pass, "manifest-license", "moon.mod declares an OSI-compatible license", ""))
      } else {
        checks.push(check(
          Manifest,
          Error,
          "manifest-license",
          "moon.mod license is not in the recognized allowlist",
          "Use MIT, Apache-2.0, BSD-3-Clause, MPL-2.0 or another OSI license.",
        ))
      }
    }
  }
}

fn require_field(checks : Array[AuditCheck], manifest : ManifestInfo, key : String) -> Unit {
  match manifest.get(key) {
    None => checks.push(check(
      Manifest,
      Error,
      "moon-mod-missing-\{key}",
      "moon.mod is missing '\{key}'",
      "Add the field before publishing to Mooncakes.",
    ))
    Some(value) => {
      if trim_ascii(value).length() == 0 {
        checks.push(check(
          Manifest,
          Error,
          "moon-mod-empty-\{key}",
          "moon.mod field '\{key}' is empty",
          "Fill a concrete value before release.",
        ))
      } else {
        checks.push(check(Manifest, Pass, "moon-mod-has-\{key}", "moon.mod has '\{key}'", ""))
      }
    }
  }
}

fn audit_readme(
  checks : Array[AuditCheck],
  readme : String,
  manifest : ManifestInfo
) -> Unit {
  let lower = ascii_lower(readme)
  if trim_ascii(readme).length() == 0 {
    checks.push(check(Readme, Error, "readme-empty", "README is empty", "Write installation, usage and validation docs."))
    return
  }
  checks.push(check(Readme, Pass, "readme-present", "README is present", ""))
  require_readme_any(checks, readme, lower, "installation", "安装", "readme-install", "README describes installation")
  require_readme_any(checks, readme, lower, "usage", "使用", "readme-usage", "README describes usage")
  require_readme_any(checks, readme, lower, "example", "示例", "readme-example", "README includes an example")
  require_readme_text(checks, lower, "moon check", "readme-check-command", "README includes moon check")
  require_readme_text(checks, lower, "moon build", "readme-build-command", "README includes moon build")
  require_readme_text(checks, lower, "moon test", "readme-test-command", "README includes moon test")
  require_readme_text(checks, lower, "moon publish --dry-run", "readme-dry-run-command", "README includes publish dry-run")
  require_readme_any(checks, readme, lower, "license", "许可证", "readme-license", "README mentions license")
  match manifest.get("name") {
    None => ()
    Some(name) => {
      if contains(readme, name) {
        checks.push(check(Readme, Pass, "readme-package-name", "README mentions the Mooncakes package name", ""))
      } else {
        checks.push(check(
          Readme,
          Warning,
          "readme-package-name",
          "README does not mention the package name from moon.mod",
          "Keep README and moon.mod package names consistent.",
        ))
      }
    }
  }
  if has_placeholder(readme) {
    checks.push(check(
      Readme,
      Warning,
      "readme-placeholder",
      "README contains placeholder text",
      "Replace placeholders before final submission.",
    ))
  }
  if contains(readme, "AI 编写") || contains(readme, "AI编写") {
    checks.push(check(
      Readme,
      Error,
      "readme-ai-trace",
      "README contains disallowed authorship wording",
      "Remove process notes that are not part of the project documentation.",
    ))
  }
}

fn require_readme_text(
  checks : Array[AuditCheck],
  lower_readme : String,
  needle : String,
  code : String,
  message : String
) -> Unit {
  if contains(lower_readme, needle) {
    checks.push(check(Readme, Pass, code, message, ""))
  } else {
    checks.push(check(
      Readme,
      Warning,
      code,
      message + " is missing",
      "Add a concise README section for this requirement.",
    ))
  }
}

fn require_readme_any(
  checks : Array[AuditCheck],
  readme : String,
  lower_readme : String,
  ascii_needle : String,
  unicode_needle : String,
  code : String,
  message : String
) -> Unit {
  if contains(lower_readme, ascii_needle) || contains(readme, unicode_needle) {
    checks.push(check(Readme, Pass, code, message, ""))
  } else {
    checks.push(check(
      Readme,
      Warning,
      code,
      message + " is missing",
      "Add a concise README section for this requirement.",
    ))
  }
}

fn audit_ci(checks : Array[AuditCheck], ci : String) -> Unit {
  let lower = ascii_lower(ci)
  if trim_ascii(ci).length() == 0 {
    checks.push(check(CI, Error, "ci-missing", "GitHub Actions workflow is missing", "Add .github/workflows/ci.yml."))
    return
  }
  checks.push(check(CI, Pass, "ci-present", "CI workflow is present", ""))
  require_ci_command(checks, lower, "moon check", "ci-moon-check")
  require_ci_command(checks, lower, "moon build", "ci-moon-build")
  require_ci_command(checks, lower, "moon test", "ci-moon-test")
  require_ci_command(checks, lower, "moon run", "ci-moon-run")
  if contains(lower, "cli.moonbitlang.com") || contains(lower, "moon version") {
    checks.push(check(CI, Pass, "ci-installs-moonbit", "CI installs or verifies MoonBit", ""))
  } else {
    checks.push(check(
      CI,
      Error,
      "ci-installs-moonbit",
      "CI does not install or verify MoonBit",
      "Install MoonBit before running moon commands.",
    ))
  }
}

fn require_ci_command(checks : Array[AuditCheck], lower_ci : String, command : String, code : String) -> Unit {
  if contains(lower_ci, command) {
    checks.push(check(CI, Pass, code, "CI runs \{command}", ""))
  } else {
    checks.push(check(
      CI,
      Error,
      code,
      "CI does not run \{command}",
      "Add this command to the workflow.",
    ))
  }
}

fn audit_license(checks : Array[AuditCheck], license_text : String) -> Unit {
  let lower = ascii_lower(license_text)
  if trim_ascii(license_text).length() == 0 {
    checks.push(check(License, Error, "license-missing", "LICENSE file is missing", "Add an OSI-approved license file."))
  } else if contains(lower, "mit license") || contains(lower, "apache license") {
    checks.push(check(License, Pass, "license-recognized", "LICENSE text is recognized", ""))
  } else {
    checks.push(check(
      License,
      Warning,
      "license-unrecognized",
      "LICENSE text was not recognized by the lightweight scanner",
      "Check that the project uses an OSI-approved license.",
    ))
  }
}

fn audit_repository(checks : Array[AuditCheck], input : AuditInput) -> Unit {
  if input.repository_public {
    checks.push(check(Repository, Pass, "repo-public", "repository is marked public", ""))
  } else {
    checks.push(check(
      Repository,
      Error,
      "repo-public",
      "repository is not marked public",
      "Make the GitHub repository public before submission.",
    ))
  }
  if input.commit_count >= 6 {
    checks.push(check(Repository, Pass, "commit-count", "commit history has at least 6 commits", ""))
  } else {
    checks.push(check(
      Repository,
      Warning,
      "commit-count",
      "commit history is too short",
      "Keep meaningful commits so development can be traced.",
    ))
  }
  if trim_ascii(input.changelog).length() > 0 {
    checks.push(check(Repository, Pass, "changelog-present", "CHANGELOG is present", ""))
  } else {
    checks.push(check(
      Repository,
      Info,
      "changelog-present",
      "CHANGELOG is not provided",
      "A small changelog helps reviewers understand release history.",
    ))
  }
}

fn audit_release(
  checks : Array[AuditCheck],
  input : AuditInput,
  manifest : ManifestInfo
) -> Unit {
  if input.package_published {
    checks.push(check(Release, Pass, "mooncakes-published", "package is marked as published", ""))
  } else {
    checks.push(check(
      Release,
      Warning,
      "mooncakes-published",
      "package is not marked as published",
      "Run moon login, moon publish --dry-run and moon publish with the owner account.",
    ))
  }
  match manifest.get("name") {
    None => ()
    Some(name) => {
      if has_placeholder(name) {
        checks.push(check(
          Release,
          Warning,
          "release-placeholder-name",
          "release package name still contains a placeholder",
          "Replace placeholder owner before moon publish.",
        ))
      } else {
        checks.push(check(Release, Pass, "release-package-name", "release package name is concrete", ""))
      }
    }
  }
}

fn is_known_osi_license(value : String) -> Bool {
  value == "MIT" ||
  value == "Apache-2.0" ||
  value == "BSD-2-Clause" ||
  value == "BSD-3-Clause" ||
  value == "MPL-2.0"
}

fn compute_score(checks : Array[AuditCheck]) -> Score {
  let mut pass_count = 0
  let mut info_count = 0
  let mut warning_count = 0
  let mut error_count = 0
  let mut index = 0
  while index < checks.length() {
    match checks[index].severity {
      Pass => pass_count += 1
      Info => info_count += 1
      Warning => warning_count += 1
      Error => error_count += 1
    }
    index += 1
  }
  let total = checks.length()
  let readiness = if total == 0 {
    0
  } else {
    let penalty = error_count * 20 + warning_count * 6 + info_count * 2
    let raw = 100 - penalty
    if raw < 0 { 0 } else { raw }
  }
  score(pass_count, info_count, warning_count, error_count, total, readiness)
}
