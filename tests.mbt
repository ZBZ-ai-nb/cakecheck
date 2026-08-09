test "parses moon.mod fields and detects duplicates" {
  let manifest = parse_manifest("name = \"owner/pkg\"\nversion = \"0.1.0\"\nname = \"owner/pkg2\"\nbroken\n")
  assert_eq(manifest.fields.length(), 3)
  assert_eq(manifest.duplicates.length(), 1)
  assert_eq(manifest.malformed_lines.length(), 1)
  assert_eq(manifest.package_name(), "owner/pkg")
  assert_true(manifest.has("version"))
}

test "validates package names and versions through audit" {
  let report = audit_project(sample_good_input())
  assert_false(report.has_errors())
  assert_true(report.score.readiness >= 90)
  assert_eq(report.package_name, "acme/cakecheck")
  assert_eq(report.version, "0.1.0")
}

test "finds risky project gaps" {
  let report = audit_project(sample_risky_input())
  assert_true(report.has_errors())
  assert_true(report.score.error_count >= 4)
  assert_true(report.score.warning_count >= 3)
}

test "README coverage checks are explicit" {
  let risky = audit_project(sample_risky_input())
  let mut found = false
  let mut index = 0
  while index < risky.checks.length() {
    if risky.checks[index].code == "readme-test-command" {
      found = true
    }
    index += 1
  }
  assert_true(found)
}

test "CI checks require build test and example commands" {
  let risky = audit_project(sample_risky_input())
  let mut missing_build = false
  let mut missing_run = false
  let mut index = 0
  while index < risky.checks.length() {
    if risky.checks[index].code == "ci-moon-build" &&
       risky.checks[index].severity == Error {
      missing_build = true
    }
    if risky.checks[index].code == "ci-moon-run" &&
       risky.checks[index].severity == Error {
      missing_run = true
    }
    index += 1
  }
  assert_true(missing_build)
  assert_true(missing_run)
}

test "exports markdown and json summaries" {
  let report = audit_project(sample_good_input())
  let markdown = report.to_markdown()
  let json = report.to_json()
  assert_true(contains(markdown, "CakeCheck Audit Report"))
  assert_true(contains(markdown, "| Severity | Category | Code | Message |"))
  assert_true(contains(json, "\"package\":\"acme/cakecheck\""))
  assert_true(contains(report.summary(), "readiness="))
}

test "score tracks pass warning info and error buckets" {
  let report = audit_project(sample_risky_input())
  assert_true(report.score.total == report.checks.length())
  assert_true(report.score.pass_count > 0)
  assert_true(report.score.readiness < 80)
}

test "README checker accepts Chinese section names" {
  let input = audit_input(
    "name = \"acme/cakecheck\"\nversion = \"0.1.0\"\nreadme = \"README.md\"\nrepository = \"https://github.com/acme/cakecheck.git\"\nlicense = \"MIT\"\ndescription = \"MoonBit package readiness auditor\"\npreferred_target = \"wasm\"\n",
    "# CakeCheck\n\n## 安装\nmoon add acme/cakecheck@0.1.0\n\n## 使用\nRun audit.\n\n## 示例\nmoon run examples/basic\n\n## 验证\nmoon check\nmoon build\nmoon test\nmoon publish --dry-run\n\n## 许可证\nMIT\n\nacme/cakecheck\n",
    "moon version\nmoon check\nmoon build\nmoon test\nmoon run examples/basic\n",
    "MIT License\n",
    "# Changelog\n",
    true,
    7,
    true,
  )
  let report = audit_project(input)
  assert_false(report.has_errors())
}

test "gate profiles distinguish release and hackathon readiness" {
  let good = audit_project(sample_good_input())
  assert_true(good.gate(Quick).passed)
  assert_true(good.gate(Release).passed)
  assert_true(good.gate(Hackathon).passed)
  let risky = audit_project(sample_risky_input())
  assert_false(risky.gate(Quick).passed)
  assert_false(risky.gate(Hackathon).passed)
  assert_true(risky.problem_count(CI) >= 3)
}

test "remediation plan prioritizes errors" {
  let risky = audit_project(sample_risky_input())
  let plan = risky.remediation_plan(3)
  assert_true(contains(plan, "Remediation Plan"))
  assert_true(contains(plan, "[ERROR]"))
  match risky.first_problem() {
    Some(item) => assert_eq(item.severity, Error)
    None => fail("expected a problem")
  }
}

test "diff reports fixed and new problems" {
  let before = audit_project(sample_risky_input())
  let after = audit_project(sample_good_input())
  let diff = diff_reports(before, after)
  assert_true(diff.readiness_delta > 0)
  assert_true(diff.fixed_codes.length() > 0)
  assert_eq(diff.new_problem_codes.length(), 0)
  assert_true(contains(diff.summary(), "delta="))
  assert_true(contains(diff.to_markdown(), "CakeCheck Diff"))
}
