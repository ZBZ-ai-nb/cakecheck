///|
pub(all) enum AcceptanceLevel {
  AcceptanceReady
  AcceptanceNearlyReady
  AcceptanceNeedsWork
  AcceptanceBlocked
} derive(Debug, Eq)

///|
pub(all) struct AcceptanceReview {
  report : AuditReport
  evidence : EvidenceMatrix
  quality : QualityMatrix
  release_plan : ReleasePlan
  level : AcceptanceLevel
  decision : String
} derive(Debug, Eq)

///|
pub fn review_acceptance(input : AuditInput) -> AcceptanceReview {
  let report = audit_project(input)
  let evidence = evidence_from_report(input, report)
  let quality = quality_from_report(input, report)
  let release_plan = release_plan_from_report(input, report)
  let level = acceptance_level(report, evidence, quality, release_plan)
  AcceptanceReview::{
    report,
    evidence,
    quality,
    release_plan,
    level,
    decision: acceptance_decision_text(level),
  }
}

///|
pub fn AcceptanceReview::is_likely_to_pass(self : AcceptanceReview) -> Bool {
  self.level == AcceptanceReady
}

///|
pub fn AcceptanceReview::is_submission_risky(self : AcceptanceReview) -> Bool {
  self.level == AcceptanceNeedsWork || self.level == AcceptanceBlocked
}

///|
pub fn AcceptanceReview::level_name(self : AcceptanceReview) -> String {
  acceptance_level_name(self.level)
}

///|
pub fn AcceptanceReview::summary(self : AcceptanceReview) -> String {
  "acceptance=\{self.level_name()}, readiness=\{self.report.score.readiness}, evidence=\{self.evidence.coverage_percent()}, quality=\{self.quality.normalized_score}"
}

///|
pub fn AcceptanceReview::blocking_reasons(
  self : AcceptanceReview,
) -> Array[String] {
  let reasons : Array[String] = []
  acceptance_collect_blocking_reasons(
    reasons,
    self.report,
    self.evidence,
    self.release_plan,
  )
  reasons
}

///|
pub fn AcceptanceReview::positive_signals(
  self : AcceptanceReview,
) -> Array[String] {
  let signals : Array[String] = []
  if self.report.score.error_count == 0 {
    signals.push("standard audit has no errors")
  }
  if self.report.score.warning_count == 0 {
    signals.push("standard audit has no warnings")
  }
  if self.evidence.coverage_percent() >= 90 {
    signals.push("acceptance evidence is almost complete")
  }
  if self.quality.is_competitive() {
    signals.push("quality matrix is competitive")
  }
  if release_plan_has_command(self.release_plan, "moon publish --dry-run") {
    signals.push("release plan includes Mooncakes dry-run validation")
  }
  signals
}

///|
pub fn AcceptanceReview::next_actions(self : AcceptanceReview) -> Array[String] {
  let actions : Array[String] = []
  let blockers = self.blocking_reasons()
  let mut blocker_index = 0
  while blocker_index < blockers.length() {
    actions.push(blockers[blocker_index])
    blocker_index += 1
  }
  let improvements = self.quality.improvement_notes()
  let mut improve_index = 0
  while improve_index < improvements.length() {
    actions.push(improvements[improve_index])
    improve_index += 1
  }
  if actions.length() == 0 {
    actions.push(
      "keep the repository public, tag the release, and preserve CI/test records",
    )
  }
  actions
}

///|
pub fn AcceptanceReview::to_markdown(self : AcceptanceReview) -> String {
  let mut out = "# Acceptance Review\n\n"
  out = out + "- Decision: " + self.decision + "\n"
  out = out + "- Level: " + self.level_name() + "\n"
  out = out +
    "- Audit readiness: " +
    self.report.score.readiness.to_string() +
    "/100\n"
  out = out +
    "- Evidence coverage: " +
    self.evidence.coverage_percent().to_string() +
    "%\n"
  out = out +
    "- Quality score: " +
    self.quality.normalized_score.to_string() +
    "/100\n"
  out = out +
    "- Release blockers: " +
    self.release_plan.blockers.length().to_string() +
    "\n\n"
  let blockers = self.blocking_reasons()
  if blockers.length() > 0 {
    out = out + "## Blocking Reasons\n\n"
    let mut blocker_index = 0
    while blocker_index < blockers.length() {
      out = out + "- " + blockers[blocker_index] + "\n"
      blocker_index += 1
    }
    out = out + "\n"
  }
  let signals = self.positive_signals()
  if signals.length() > 0 {
    out = out + "## Positive Signals\n\n"
    let mut signal_index = 0
    while signal_index < signals.length() {
      out = out + "- " + signals[signal_index] + "\n"
      signal_index += 1
    }
    out = out + "\n"
  }
  out = out + "## Next Actions\n\n"
  let actions = self.next_actions()
  let mut action_index = 0
  while action_index < actions.length() {
    out = out + "- " + actions[action_index] + "\n"
    action_index += 1
  }
  out
}

///|
pub fn acceptance_level_name(level : AcceptanceLevel) -> String {
  match level {
    AcceptanceReady => "ready"
    AcceptanceNearlyReady => "nearly-ready"
    AcceptanceNeedsWork => "needs-work"
    AcceptanceBlocked => "blocked"
  }
}

///|
pub fn acceptance_reviews_table(reviews : Array[AcceptanceReview]) -> String {
  let mut out = "| # | Level | Readiness | Evidence | Quality | Decision |\n| --- | --- | --- | --- | --- | --- |\n"
  let mut index = 0
  while index < reviews.length() {
    let review = reviews[index]
    out = out + "| " + (index + 1).to_string()
    out = out + " | " + review.level_name()
    out = out + " | " + review.report.score.readiness.to_string()
    out = out + " | " + review.evidence.coverage_percent().to_string() + "%"
    out = out + " | " + review.quality.normalized_score.to_string()
    out = out + " | " + review.decision + " |\n"
    index += 1
  }
  out
}

///|
fn acceptance_level(
  report : AuditReport,
  evidence : EvidenceMatrix,
  quality : QualityMatrix,
  release_plan : ReleasePlan,
) -> AcceptanceLevel {
  if report.score.error_count > 0 ||
    acceptance_missing_hard_evidence(evidence) ||
    release_plan.is_blocked() {
    return AcceptanceBlocked
  }
  if report.score.warning_count == 0 &&
    evidence.is_complete() &&
    quality.normalized_score >= 85 {
    return AcceptanceReady
  }
  if evidence.coverage_percent() >= 85 && quality.normalized_score >= 75 {
    AcceptanceNearlyReady
  } else {
    AcceptanceNeedsWork
  }
}

///|
fn acceptance_decision_text(level : AcceptanceLevel) -> String {
  match level {
    AcceptanceReady => "likely to pass local acceptance checks"
    AcceptanceNearlyReady =>
      "close to acceptance, but review the remaining evidence"
    AcceptanceNeedsWork =>
      "not ready yet; improve documentation, CI or quality signals"
    AcceptanceBlocked => "blocked by one or more hard acceptance requirements"
  }
}

///|
fn acceptance_missing_hard_evidence(evidence : EvidenceMatrix) -> Bool {
  !evidence.has("moonbit-project") ||
  !evidence.has("package-name") ||
  !evidence.has("version") ||
  !evidence.has("readme-present") ||
  !evidence.has("ci-check") ||
  !evidence.has("ci-build") ||
  !evidence.has("ci-test") ||
  !evidence.has("license") ||
  !evidence.has("public-repo") ||
  !evidence.has("mooncakes")
}

///|
fn acceptance_collect_blocking_reasons(
  reasons : Array[String],
  report : AuditReport,
  evidence : EvidenceMatrix,
  release_plan : ReleasePlan,
) -> Unit {
  if report.score.error_count > 0 {
    reasons.push("fix audit errors before acceptance")
  }
  acceptance_add_missing_evidence(
    reasons, evidence, "moonbit-project", "MoonBit project metadata must be valid",
  )
  acceptance_add_missing_evidence(
    reasons, evidence, "package-name", "Mooncakes package namespace must be valid",
  )
  acceptance_add_missing_evidence(
    reasons, evidence, "version", "moon.mod version must be semantic",
  )
  acceptance_add_missing_evidence(
    reasons, evidence, "readme-present", "README must exist",
  )
  acceptance_add_missing_evidence(
    reasons, evidence, "ci-check", "CI must run moon check",
  )
  acceptance_add_missing_evidence(
    reasons, evidence, "ci-build", "CI must run moon build",
  )
  acceptance_add_missing_evidence(
    reasons, evidence, "ci-test", "CI must run moon test",
  )
  acceptance_add_missing_evidence(
    reasons, evidence, "license", "LICENSE must be complete and OSI-approved",
  )
  acceptance_add_missing_evidence(
    reasons, evidence, "public-repo", "GitHub repository must be public",
  )
  acceptance_add_missing_evidence(
    reasons, evidence, "mooncakes", "package must be published to mooncakes.io",
  )
  let mut index = 0
  while index < release_plan.blockers.length() {
    acceptance_push_unique(reasons, release_plan.blockers[index])
    index += 1
  }
}

///|
fn acceptance_add_missing_evidence(
  reasons : Array[String],
  evidence : EvidenceMatrix,
  code : String,
  message : String,
) -> Unit {
  if !evidence.has(code) {
    acceptance_push_unique(reasons, message)
  }
}

///|
fn acceptance_push_unique(items : Array[String], value : String) -> Unit {
  let mut index = 0
  while index < items.length() {
    if items[index] == value {
      return
    }
    index += 1
  }
  items.push(value)
}
