///|
pub fn build_quality_matrix(input : AuditInput) -> QualityMatrix {
  quality_from_report(input, audit_project(input))
}

///|
pub fn quality_from_report(
  input : AuditInput,
  report : AuditReport,
) -> QualityMatrix {
  let manifest = parse_manifest(input.moon_mod)
  let readme = analyze_readme(input.readme)
  let workflow = analyze_workflow(input.ci)
  let license = analyze_license(input.license_text)
  let namespace_data = namespace_from_manifest(manifest)
  let release = build_release_plan(input)
  let axes : Array[QualityAxis] = []
  axes.push(
    quality_axis(
      "metadata",
      quality_metadata_score(manifest, namespace_data, report),
      15,
      quality_metadata_note(manifest, namespace_data),
    ),
  )
  axes.push(
    quality_axis(
      "readme",
      readme.coverage_score(),
      18,
      quality_readme_note(readme),
    ),
  )
  axes.push(
    quality_axis("ci", workflow.coverage_score(), 16, quality_ci_note(workflow)),
  )
  axes.push(
    quality_axis(
      "license",
      license.completeness_score(),
      12,
      quality_license_note(license),
    ),
  )
  axes.push(
    quality_axis(
      "repository",
      quality_repository_score(input),
      12,
      quality_repository_note(input),
    ),
  )
  axes.push(
    quality_axis(
      "release",
      quality_release_score(input, release),
      15,
      quality_release_note(input, release),
    ),
  )
  axes.push(
    quality_axis(
      "maintainability",
      quality_maintainability_score(input, report),
      12,
      quality_maintainability_note(input, report),
    ),
  )
  quality_matrix(
    axes,
    quality_weighted_score(axes),
    quality_max_score(axes),
    quality_normalized_score(axes),
  )
}

///|
pub fn QualityAxis::weighted_points(self : QualityAxis) -> Int {
  quality_clamp(self.score) * self.weight
}

///|
pub fn QualityAxis::max_points(self : QualityAxis) -> Int {
  self.weight * 100
}

///|
pub fn QualityAxis::rating(self : QualityAxis) -> String {
  let score = quality_clamp(self.score)
  if score >= 90 {
    "excellent"
  } else if score >= 75 {
    "good"
  } else if score >= 60 {
    "fair"
  } else {
    "weak"
  }
}

///|
pub fn QualityAxis::markdown_row(self : QualityAxis) -> String {
  "| " +
  self.name +
  " | " +
  quality_clamp(self.score).to_string() +
  " | " +
  self.weight.to_string() +
  " | " +
  self.rating() +
  " | " +
  self.note +
  " |\n"
}

///|
pub fn QualityMatrix::grade(self : QualityMatrix) -> String {
  if self.normalized_score >= 90 {
    "A"
  } else if self.normalized_score >= 80 {
    "B"
  } else if self.normalized_score >= 70 {
    "C"
  } else if self.normalized_score >= 60 {
    "D"
  } else {
    "E"
  }
}

///|
pub fn QualityMatrix::is_competitive(self : QualityMatrix) -> Bool {
  self.normalized_score >= 85 && self.lowest_score() >= 65
}

///|
pub fn QualityMatrix::lowest_score(self : QualityMatrix) -> Int {
  if self.axes.length() == 0 {
    return 0
  }
  let mut value = quality_clamp(self.axes[0].score)
  let mut index = 1
  while index < self.axes.length() {
    let score = quality_clamp(self.axes[index].score)
    if score < value {
      value = score
    }
    index += 1
  }
  value
}

///|
pub fn QualityMatrix::lowest_axis_name(self : QualityMatrix) -> String {
  if self.axes.length() == 0 {
    return ""
  }
  let mut name = self.axes[0].name
  let mut score = quality_clamp(self.axes[0].score)
  let mut index = 1
  while index < self.axes.length() {
    let current = quality_clamp(self.axes[index].score)
    if current < score {
      score = current
      name = self.axes[index].name
    }
    index += 1
  }
  name
}

///|
pub fn QualityMatrix::improvement_notes(self : QualityMatrix) -> Array[String] {
  let notes : Array[String] = []
  let mut index = 0
  while index < self.axes.length() {
    let axis = self.axes[index]
    if quality_clamp(axis.score) < 80 {
      notes.push(axis.name + ": " + axis.note)
    }
    index += 1
  }
  notes
}

///|
pub fn QualityMatrix::summary(self : QualityMatrix) -> String {
  "quality=\{self.normalized_score}/100 grade=\{self.grade()} lowest=\{self.lowest_axis_name()}"
}

///|
pub fn QualityMatrix::to_markdown(self : QualityMatrix) -> String {
  let mut out = "## Quality Matrix\n\n"
  out = out + "- Score: " + self.normalized_score.to_string() + "/100\n"
  out = out + "- Grade: " + self.grade() + "\n"
  out = out + "- Competitive: " + bool_text(self.is_competitive()) + "\n"
  out = out + "- Lowest axis: " + self.lowest_axis_name() + "\n\n"
  out = out +
    "| Axis | Score | Weight | Rating | Note |\n| --- | --- | --- | --- | --- |\n"
  let mut index = 0
  while index < self.axes.length() {
    out = out + self.axes[index].markdown_row()
    index += 1
  }
  let notes = self.improvement_notes()
  if notes.length() > 0 {
    out = out + "\n### Improvements\n\n"
    let mut note_index = 0
    while note_index < notes.length() {
      out = out + "- " + notes[note_index] + "\n"
      note_index += 1
    }
  }
  out
}

///|
pub fn quality_matrix_table(matrices : Array[QualityMatrix]) -> String {
  let mut out = "| # | Score | Grade | Competitive | Lowest |\n| --- | --- | --- | --- | --- |\n"
  let mut index = 0
  while index < matrices.length() {
    let matrix = matrices[index]
    out = out + "| " + (index + 1).to_string()
    out = out + " | " + matrix.normalized_score.to_string()
    out = out + " | " + matrix.grade()
    out = out + " | " + bool_text(matrix.is_competitive())
    out = out + " | " + matrix.lowest_axis_name() + " |\n"
    index += 1
  }
  out
}

///|
pub fn quality_axis_named(
  matrix : QualityMatrix,
  name : String,
) -> QualityAxis? {
  let mut index = 0
  while index < matrix.axes.length() {
    if matrix.axes[index].name == name {
      return Some(matrix.axes[index])
    }
    index += 1
  }
  None
}

///|
fn quality_metadata_score(
  manifest : ManifestInfo,
  namespace_data : NamespaceInfo,
  report : AuditReport,
) -> Int {
  let mut score = 0
  if manifest.has("name") {
    score += 15
  }
  if manifest.has("version") {
    score += 15
  }
  if manifest.has("repository") {
    score += 15
  }
  if manifest.has("license") {
    score += 10
  }
  if manifest.has("description") {
    score += 10
  }
  if namespace_data.valid {
    score += 20
  }
  if report.score.error_count == 0 {
    score += 15
  }
  quality_clamp(score)
}

///|
fn quality_metadata_note(
  manifest : ManifestInfo,
  namespace_data : NamespaceInfo,
) -> String {
  if !namespace_data.valid {
    "fix the package namespace format"
  } else if manifest.duplicates.length() > 0 {
    "remove duplicate moon.mod fields"
  } else if manifest.malformed_lines.length() > 0 {
    "fix malformed moon.mod lines"
  } else {
    "metadata is coherent"
  }
}

///|
fn quality_readme_note(readme : ReadmeMetrics) -> String {
  if readme.is_complete() {
    "README covers the reviewer's first-run workflow"
  } else {
    "missing: " + quality_join_strings(readme.missing_topics())
  }
}

///|
fn quality_ci_note(workflow : WorkflowInfo) -> String {
  if workflow.is_acceptance_ready() {
    "CI covers check, build, test and example execution"
  } else {
    "missing: " + quality_join_strings(workflow.missing_commands())
  }
}

///|
fn quality_license_note(license : LicenseFacts) -> String {
  if license.is_publishable() {
    "license is recognized and publishable"
  } else {
    "add a complete OSI-approved LICENSE file"
  }
}

///|
fn quality_repository_score(input : AuditInput) -> Int {
  let mut score = 0
  if input.repository_public {
    score += 45
  }
  if input.commit_count >= 5 {
    score += 35
  }
  if trim_ascii(input.changelog).length() > 0 {
    score += 20
  }
  quality_clamp(score)
}

///|
fn quality_repository_note(input : AuditInput) -> String {
  if !input.repository_public {
    "make the GitHub repository public"
  } else if input.commit_count < 5 {
    "keep at least five meaningful contest-period commits"
  } else if trim_ascii(input.changelog).length() == 0 {
    "add a small changelog"
  } else {
    "repository evidence is traceable"
  }
}

///|
fn quality_release_score(input : AuditInput, plan : ReleasePlan) -> Int {
  let mut score = 100
  if plan.is_blocked() {
    score -= plan.blockers.length() * 12
  }
  if input.package_published {
    score += 10
  }
  quality_clamp(score)
}

///|
fn quality_release_note(input : AuditInput, plan : ReleasePlan) -> String {
  if input.package_published {
    "package is marked as published"
  } else if plan.blockers.length() == 0 {
    "ready for moon publish after logging into Mooncakes"
  } else {
    "blocker: " + plan.first_blocker()
  }
}

///|
fn quality_maintainability_score(
  input : AuditInput,
  report : AuditReport,
) -> Int {
  let readme = analyze_readme(input.readme)
  let mut score = 45
  if readme.has_support_scope {
    score += 15
  }
  if readme.has_unsupported_scope {
    score += 15
  }
  if trim_ascii(input.changelog).length() > 0 {
    score += 10
  }
  if report.score.warning_count == 0 {
    score += 10
  }
  if input.commit_count >= 8 {
    score += 5
  }
  quality_clamp(score)
}

///|
fn quality_maintainability_note(
  input : AuditInput,
  report : AuditReport,
) -> String {
  let readme = analyze_readme(input.readme)
  if !readme.has_support_scope {
    "document supported scope"
  } else if !readme.has_unsupported_scope {
    "document unsupported or future scope"
  } else if report.score.warning_count > 0 {
    "resolve remaining audit warnings"
  } else {
    "maintenance boundary is clear"
  }
}

///|
fn quality_weighted_score(axes : Array[QualityAxis]) -> Int {
  let mut total = 0
  let mut index = 0
  while index < axes.length() {
    total += axes[index].weighted_points()
    index += 1
  }
  total
}

///|
fn quality_max_score(axes : Array[QualityAxis]) -> Int {
  let mut total = 0
  let mut index = 0
  while index < axes.length() {
    total += axes[index].max_points()
    index += 1
  }
  total
}

///|
fn quality_normalized_score(axes : Array[QualityAxis]) -> Int {
  let max = quality_max_score(axes)
  if max == 0 {
    0
  } else {
    quality_weighted_score(axes) * 100 / max
  }
}

///|
fn quality_clamp(value : Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
fn quality_join_strings(items : Array[String]) -> String {
  if items.length() == 0 {
    return "none"
  }
  let mut out = ""
  let mut index = 0
  while index < items.length() {
    if index > 0 {
      out = out + ", "
    }
    out = out + items[index]
    index += 1
  }
  out
}
