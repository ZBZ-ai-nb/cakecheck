///|
pub fn build_release_plan(input : AuditInput) -> ReleasePlan {
  let report = audit_project(input)
  let manifest = parse_manifest(input.moon_mod)
  let namespace_data = namespace_from_manifest(manifest)
  let version = parse_semver(report.version)
  let workflow = analyze_workflow(input.ci)
  let license = analyze_license(input.license_text)
  let blockers : Array[String] = []
  release_collect_blockers(
    blockers, input, report, namespace_data, version, workflow, license,
  )
  release_plan(
    report.package_name,
    report.version,
    release_default_steps(report.package_name),
    blockers,
  )
}

///|
pub fn release_plan_from_report(
  input : AuditInput,
  report : AuditReport,
) -> ReleasePlan {
  let manifest = parse_manifest(input.moon_mod)
  let namespace_data = namespace_from_manifest(manifest)
  let version = parse_semver(report.version)
  let workflow = analyze_workflow(input.ci)
  let license = analyze_license(input.license_text)
  let blockers : Array[String] = []
  release_collect_blockers(
    blockers, input, report, namespace_data, version, workflow, license,
  )
  release_plan(
    report.package_name,
    report.version,
    release_default_steps(report.package_name),
    blockers,
  )
}

///|
pub fn ReleaseStep::label(self : ReleaseStep) -> String {
  if self.required {
    "required"
  } else {
    "optional"
  }
}

///|
pub fn ReleaseStep::markdown_row(self : ReleaseStep) -> String {
  "| " +
  self.index.to_string() +
  " | `" +
  self.command +
  "`" +
  " | " +
  self.label() +
  " | " +
  self.description +
  " |\n"
}

///|
pub fn ReleaseStep::is_validation(self : ReleaseStep) -> Bool {
  contains(self.command, "moon check") ||
  contains(self.command, "moon build") ||
  contains(self.command, "moon test")
}

///|
pub fn ReleaseStep::is_publish(self : ReleaseStep) -> Bool {
  contains(self.command, "moon publish")
}

///|
pub fn ReleasePlan::is_blocked(self : ReleasePlan) -> Bool {
  self.blockers.length() > 0
}

///|
pub fn ReleasePlan::required_steps(self : ReleasePlan) -> Array[ReleaseStep] {
  let items : Array[ReleaseStep] = []
  let mut index = 0
  while index < self.steps.length() {
    if self.steps[index].required {
      items.push(self.steps[index])
    }
    index += 1
  }
  items
}

///|
pub fn ReleasePlan::optional_steps(self : ReleasePlan) -> Array[ReleaseStep] {
  let items : Array[ReleaseStep] = []
  let mut index = 0
  while index < self.steps.length() {
    if !self.steps[index].required {
      items.push(self.steps[index])
    }
    index += 1
  }
  items
}

///|
pub fn ReleasePlan::validation_steps(self : ReleasePlan) -> Array[ReleaseStep] {
  let items : Array[ReleaseStep] = []
  let mut index = 0
  while index < self.steps.length() {
    if self.steps[index].is_validation() {
      items.push(self.steps[index])
    }
    index += 1
  }
  items
}

///|
pub fn ReleasePlan::publish_steps(self : ReleasePlan) -> Array[ReleaseStep] {
  let items : Array[ReleaseStep] = []
  let mut index = 0
  while index < self.steps.length() {
    if self.steps[index].is_publish() {
      items.push(self.steps[index])
    }
    index += 1
  }
  items
}

///|
pub fn ReleasePlan::first_blocker(self : ReleasePlan) -> String {
  if self.blockers.length() == 0 {
    ""
  } else {
    self.blockers[0]
  }
}

///|
pub fn ReleasePlan::summary(self : ReleasePlan) -> String {
  let status = if self.is_blocked() { "blocked" } else { "ready" }
  "release \{status}: package=\{self.package_name}, version=\{self.version}, blockers=\{self.blockers.length()}"
}

///|
pub fn ReleasePlan::commands(self : ReleasePlan) -> Array[String] {
  let commands : Array[String] = []
  let mut index = 0
  while index < self.steps.length() {
    commands.push(self.steps[index].command)
    index += 1
  }
  commands
}

///|
pub fn ReleasePlan::command_script(self : ReleasePlan) -> String {
  let mut out = "# Release validation for " + self.package_name + "\n"
  let mut index = 0
  while index < self.steps.length() {
    let step = self.steps[index]
    if step.required {
      out = out + step.command + "\n"
    } else {
      out = out + "# optional: " + step.command + "\n"
    }
    index += 1
  }
  out
}

///|
pub fn ReleasePlan::to_markdown(self : ReleasePlan) -> String {
  let mut out = "## Release Plan\n\n"
  let status = if self.is_blocked() { "blocked" } else { "ready" }
  out = out + "- Package: `" + self.package_name + "`\n"
  out = out + "- Version: `" + self.version + "`\n"
  out = out + "- Status: " + status + "\n"
  out = out + "- Blockers: " + self.blockers.length().to_string() + "\n\n"
  if self.blockers.length() > 0 {
    out = out + "### Blockers\n\n"
    let mut blocker_index = 0
    while blocker_index < self.blockers.length() {
      out = out + "- " + self.blockers[blocker_index] + "\n"
      blocker_index += 1
    }
    out = out + "\n"
  }
  out = out + "### Steps\n\n"
  out = out +
    "| # | Command | Required | Purpose |\n| --- | --- | --- | --- |\n"
  let mut index = 0
  while index < self.steps.length() {
    out = out + self.steps[index].markdown_row()
    index += 1
  }
  out
}

///|
pub fn release_plan_table(plans : Array[ReleasePlan]) -> String {
  let mut out = "| Package | Version | Status | Blockers | Required steps |\n| --- | --- | --- | --- | --- |\n"
  let mut index = 0
  while index < plans.length() {
    let plan = plans[index]
    let status = if plan.is_blocked() { "blocked" } else { "ready" }
    out = out + "| `" + plan.package_name + "`"
    out = out + " | `" + plan.version + "`"
    out = out + " | " + status
    out = out + " | " + plan.blockers.length().to_string()
    out = out + " | " + plan.required_steps().length().to_string() + " |\n"
    index += 1
  }
  out
}

///|
pub fn release_plan_has_command(plan : ReleasePlan, command : String) -> Bool {
  let mut index = 0
  while index < plan.steps.length() {
    if contains(plan.steps[index].command, command) {
      return true
    }
    index += 1
  }
  false
}

///|
fn release_default_steps(package_name : String) -> Array[ReleaseStep] {
  let steps : Array[ReleaseStep] = []
  steps.push(
    release_step(
      1, "moon check --deny-warn", true, "strict type and warning validation",
    ),
  )
  steps.push(release_step(2, "moon build", true, "build all package targets"))
  steps.push(
    release_step(
      3, "moon test --deny-warn", true, "run tests with warnings treated as failures",
    ),
  )
  steps.push(
    release_step(
      4, "moon run examples/basic", true, "execute the runnable example used by reviewers",
    ),
  )
  steps.push(
    release_step(
      5, "moon publish --dry-run", true, "validate Mooncakes package metadata without publishing",
    ),
  )
  steps.push(
    release_step(
      6, "git status --short --branch", false, "confirm the worktree before tagging",
    ),
  )
  steps.push(
    release_step(
      7,
      "git tag v" + package_name + "-0.1.0",
      false,
      "optional release tag, adjust to actual version",
    ),
  )
  steps.push(
    release_step(
      8, "moon publish", true, "publish the package with the logged-in Mooncakes account",
    ),
  )
  steps
}

///|
fn release_collect_blockers(
  blockers : Array[String],
  input : AuditInput,
  report : AuditReport,
  namespace_data : NamespaceInfo,
  version : SemVerInfo,
  workflow : WorkflowInfo,
  license : LicenseFacts,
) -> Unit {
  release_add_blocker_if(
    blockers,
    report.score.error_count > 0,
    "audit report still has errors",
  )
  release_add_blocker_if(
    blockers,
    !namespace_data.valid,
    "moon.mod package namespace is invalid",
  )
  release_add_blocker_if(
    blockers,
    !version.valid,
    "moon.mod version is not valid semver",
  )
  release_add_blocker_if(
    blockers,
    !workflow.is_acceptance_ready(),
    "CI workflow does not cover check/build/test/run",
  )
  release_add_blocker_if(
    blockers,
    !license.is_publishable(),
    "LICENSE is missing or not recognized as publishable",
  )
  release_add_blocker_if(
    blockers,
    !input.repository_public,
    "GitHub repository must be public before acceptance",
  )
  release_add_blocker_if(
    blockers,
    input.commit_count < 5,
    "development history should include meaningful commits",
  )
  release_add_blocker_if(
    blockers,
    trim_ascii(input.readme).length() == 0,
    "README must be present and useful",
  )
  release_add_blocker_if(
    blockers,
    !input.package_published,
    "package is not yet published to mooncakes.io",
  )
}

///|
fn release_add_blocker_if(
  blockers : Array[String],
  condition : Bool,
  message : String,
) -> Unit {
  if condition && !release_blocker_seen(blockers, message) {
    blockers.push(message)
  }
}

///|
fn release_blocker_seen(blockers : Array[String], message : String) -> Bool {
  let mut index = 0
  while index < blockers.length() {
    if blockers[index] == message {
      return true
    }
    index += 1
  }
  false
}
