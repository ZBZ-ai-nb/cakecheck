///|
test "parses moon.mod fields and detects duplicates" {
  let manifest = parse_manifest(
    "name = \"owner/pkg\"\nversion = \"0.1.0\"\nname = \"owner/pkg2\"\nbroken\n",
  )
  assert_eq(manifest.fields.length(), 3)
  assert_eq(manifest.duplicates.length(), 1)
  assert_eq(manifest.malformed_lines.length(), 1)
  assert_eq(manifest.package_name(), "owner/pkg")
  assert_true(manifest.has("version"))
}

///|
test "validates package names and versions through audit" {
  let report = audit_project(sample_good_input())
  assert_false(report.has_errors())
  assert_true(report.score.readiness >= 90)
  assert_eq(report.package_name, "ZBZ-ai-nb/cakecheck")
  assert_eq(report.version, "0.1.0")
}

///|
test "finds risky project gaps" {
  let report = audit_project(sample_risky_input())
  assert_true(report.has_errors())
  assert_true(report.score.error_count >= 4)
  assert_true(report.score.warning_count >= 3)
}

///|
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

///|
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

///|
test "exports markdown and json summaries" {
  let report = audit_project(sample_good_input())
  let markdown = report.to_markdown()
  let json = report.to_json()
  assert_true(contains(markdown, "CakeCheck Audit Report"))
  assert_true(contains(markdown, "| Severity | Category | Code | Message |"))
  assert_true(contains(json, "\"package\":\"ZBZ-ai-nb/cakecheck\""))
  assert_true(contains(report.summary(), "readiness="))
}

///|
test "score tracks pass warning info and error buckets" {
  let report = audit_project(sample_risky_input())
  assert_true(report.score.total == report.checks.length())
  assert_true(report.score.pass_count > 0)
  assert_true(report.score.readiness < 80)
}

///|
test "README checker accepts Chinese section names" {
  let input = audit_input(
    "name = \"acme/cakecheck\"\nversion = \"0.1.0\"\nreadme = \"README.md\"\nrepository = \"https://github.com/acme/cakecheck.git\"\nlicense = \"MIT\"\ndescription = \"MoonBit package readiness auditor\"\npreferred_target = \"wasm\"\n",
    "# CakeCheck\n\n## 安装\nmoon add acme/cakecheck@0.1.0\n\n## 使用\nRun audit.\n\n## 示例\nmoon run examples/basic\n\n## 验证\nmoon check\nmoon build\nmoon test\nmoon publish --dry-run\n\n## 许可证\nMIT\n\nacme/cakecheck\n",
    "moon version\nmoon check\nmoon build\nmoon test\nmoon run examples/basic\n",
    "MIT License\n", "# Changelog\n", true, 7, true,
  )
  let report = audit_project(input)
  assert_false(report.has_errors())
}

///|
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

///|
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

///|
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

///|
test "semver analyzer parses prerelease metadata and bump intent" {
  let info = parse_semver("1.2.3-alpha.1+build.5")
  assert_true(info.valid)
  assert_eq(info.major, 1)
  assert_eq(info.minor, 2)
  assert_eq(info.patch, 3)
  assert_true(info.is_prerelease())
  assert_true(info.has_build_metadata())
  assert_eq(info.core(), "1.2.3")
  assert_eq(info.release_channel(), "prerelease")
  assert_true(compare_semver("1.0.0-alpha.1", "1.0.0") < 0)
  assert_eq(classify_version_bump("1.2.3", "1.3.0"), Minor)
  assert_eq(version_bump_name(Patch), "patch")
  assert_eq(recommend_release_version("1.2.3", Patch), "1.2.4")
  assert_true(contains(info.to_markdown(), "Version Analysis"))
}

///|
test "namespace analyzer aligns Mooncakes name with GitHub repository" {
  let info = analyze_namespace(
    "ZBZ-ai-nb/cakecheck", "https://github.com/ZBZ-ai-nb/cakecheck.git",
  )
  assert_true(info.valid)
  assert_eq(info.owner, "ZBZ-ai-nb")
  assert_eq(info.package_name, "cakecheck")
  assert_true(info.owner_matches_github)
  assert_true(info.package_matches_repo)
  assert_true(info.is_publishable())
  assert_eq(
    info.repository_git_url(),
    "https://github.com/ZBZ-ai-nb/cakecheck.git",
  )
  assert_true(contains(info.mooncakes_url(), "cakecheck"))
  assert_eq(
    package_name_from_repository("git@github.com:ZBZ-ai-nb/cakecheck.git"),
    "ZBZ-ai-nb/cakecheck",
  )
  assert_true(contains(namespace_alignment_table([info]), "cakecheck"))
}

///|
test "readme workflow and license analyzers expose richer metrics" {
  let input = sample_acceptance_input()
  let readme = analyze_readme(input.readme)
  let workflow = analyze_workflow(input.ci)
  let license = analyze_license(input.license_text)
  assert_true(readme.is_complete())
  assert_true(readme.has_support_scope)
  assert_true(readme.has_unsupported_scope)
  assert_true(readme.command_count >= 5)
  assert_true(workflow.is_acceptance_ready())
  assert_true(workflow.has_publish_dry_run)
  assert_true(workflow.coverage_score() >= 95)
  assert_true(license.is_publishable())
  assert_eq(license_family_name(license.family), "MIT")
  assert_true(contains(readme_topic_table(readme), "installation"))
  assert_true(contains(workflow_command_table(workflow), "moon test"))
  assert_true(contains(license.to_markdown(), "License Facts"))
}

///|
test "evidence matrix summarizes acceptance requirements" {
  let matrix = build_acceptance_evidence(sample_acceptance_input())
  assert_true(matrix.is_complete())
  assert_eq(matrix.missing_count, 0)
  assert_eq(matrix.acceptance_label(), "complete")
  assert_true(matrix.coverage_percent() == 100)
  assert_true(matrix.has("mooncakes"))
  assert_eq(matrix.missing_label_text(), "none")
  assert_true(contains(matrix.to_markdown(), "Acceptance Evidence"))
  assert_true(contains(matrix.to_json(), "\"coverage\":100"))
}

///|
test "release plan reports blockers and validation commands" {
  let ready = build_release_plan(sample_acceptance_input())
  assert_false(ready.is_blocked())
  assert_true(ready.required_steps().length() >= 5)
  assert_true(ready.validation_steps().length() >= 3)
  assert_true(ready.publish_steps().length() >= 2)
  assert_true(release_plan_has_command(ready, "moon publish --dry-run"))
  assert_true(contains(ready.command_script(), "moon test --deny-warn"))
  assert_true(contains(ready.to_markdown(), "Release Plan"))
  let blocked = build_release_plan(sample_risky_input())
  assert_true(blocked.is_blocked())
  assert_true(blocked.blockers.length() > 0)
  assert_true(contains(release_plan_table([ready, blocked]), "Blockers"))
}

///|
test "quality matrix and acceptance review combine all signals" {
  let review = review_acceptance(sample_acceptance_input())
  assert_true(review.is_likely_to_pass())
  assert_false(review.is_submission_risky())
  assert_eq(review.level, AcceptanceReady)
  assert_true(review.quality.is_competitive())
  assert_true(review.positive_signals().length() >= 3)
  assert_true(review.next_actions().length() > 0)
  assert_true(contains(review.summary(), "acceptance=ready"))
  assert_true(contains(review.to_markdown(), "Acceptance Review"))
  assert_true(contains(acceptance_reviews_table([review]), "Decision"))
  match quality_axis_named(review.quality, "ci") {
    Some(axis) => assert_true(axis.score >= 95)
    None => fail("expected ci axis")
  }
}

///|
fn sample_acceptance_input() -> AuditInput {
  audit_input(
    "name = \"ZBZ-ai-nb/cakecheck\"\nversion = \"0.1.0\"\nreadme = \"README.md\"\nrepository = \"https://github.com/ZBZ-ai-nb/cakecheck.git\"\nlicense = \"MIT\"\ndescription = \"MoonBit package readiness auditor for Mooncakes releases\"\npreferred_target = \"wasm\"\n",
    "# CakeCheck\n\nPackage: ZBZ-ai-nb/cakecheck\n\n## Installation\n\n```bash\nmoon add ZBZ-ai-nb/cakecheck@0.1.0\n```\n\n## Usage\n\n```bash\nmoon run cmd/main\n```\n\n## Example\n\n```bash\nmoon run examples/basic\n```\n\n## Validation\n\n```bash\nmoon check --target all\nmoon build\nmoon test --target all\nmoon publish --dry-run\n```\n\n## Support scope\n\nAudits MoonBit package metadata, README, CI, license, repository and release evidence.\n\n## Unsupported scope\n\nIt does not upload packages or change GitHub settings automatically.\n\n## License\n\nMIT\n",
    "name: CI\njobs:\n  test:\n    steps:\n      - uses: actions/checkout@v4\n      - run: curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash\n      - run: moon check --target all\n      - run: moon build\n      - run: moon test --target all\n      - run: moon run examples/basic\n      - run: moon publish --dry-run\n",
    "MIT License\n\nCopyright (c) 2026 Zhang Bingzheng\n\nPermission is hereby granted, free of charge, to any person obtaining a copy\nof this software and associated documentation files.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND.\n",
    "# Changelog\n\n## 0.1.0\n\n- Initial public release.\n", true, 10, true,
  )
}
