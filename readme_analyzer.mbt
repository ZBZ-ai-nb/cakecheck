///|
pub fn analyze_readme(readme : String) -> ReadmeMetrics {
  let lines = split_lines(readme)
  let sections = collect_sections(lines)
  let mut heading_count = 0
  let mut code_block_count = 0
  let mut command_count = 0
  let mut link_count = 0
  let mut bullet_count = 0
  let mut in_fence = false
  let mut index = 0
  while index < lines.length() {
    let line = lines[index]
    if is_heading_line(line) {
      heading_count += 1
    }
    if is_fence_line(line) {
      code_block_count += 1
      in_fence = !in_fence
    } else if in_fence && is_command_line(line) {
      command_count += 1
    }
    if is_markdown_link_line(line) {
      link_count += 1
    }
    if is_bullet_line(line) || is_numbered_line(line) {
      bullet_count += 1
    }
    index += 1
  }
  readme_metrics(
    lines.length(),
    heading_count,
    code_block_count / 2,
    command_count,
    link_count,
    bullet_count,
    readme_has_installation(readme),
    readme_has_usage(readme),
    readme_has_example(readme),
    readme_has_validation(readme),
    readme_has_license(readme),
    readme_has_support_scope(readme),
    readme_has_unsupported_scope(readme),
    sections,
  )
}

///|
pub fn ReadmeMetrics::coverage_score(self : ReadmeMetrics) -> Int {
  let mut score = 0
  if self.has_installation {
    score += 15
  }
  if self.has_usage {
    score += 15
  }
  if self.has_example {
    score += 15
  }
  if self.has_validation {
    score += 15
  }
  if self.has_license {
    score += 10
  }
  if self.has_support_scope {
    score += 10
  }
  if self.has_unsupported_scope {
    score += 10
  }
  if self.code_block_count > 0 {
    score += 5
  }
  if self.command_count > 0 {
    score += 5
  }
  score
}

///|
pub fn ReadmeMetrics::is_complete(self : ReadmeMetrics) -> Bool {
  self.coverage_score() >= 90 &&
  self.heading_count >= 6 &&
  self.command_count >= 3
}

///|
pub fn ReadmeMetrics::summary(self : ReadmeMetrics) -> String {
  "readme lines=\{self.line_count}, headings=\{self.heading_count}, commands=\{self.command_count}, coverage=\{self.coverage_score()}"
}

///|
pub fn ReadmeMetrics::missing_topics(self : ReadmeMetrics) -> Array[String] {
  let missing : Array[String] = []
  if !self.has_installation {
    missing.push("installation")
  }
  if !self.has_usage {
    missing.push("usage")
  }
  if !self.has_example {
    missing.push("example")
  }
  if !self.has_validation {
    missing.push("validation")
  }
  if !self.has_license {
    missing.push("license")
  }
  if !self.has_support_scope {
    missing.push("support scope")
  }
  if !self.has_unsupported_scope {
    missing.push("unsupported scope")
  }
  missing
}

///|
pub fn ReadmeMetrics::to_markdown(self : ReadmeMetrics) -> String {
  let mut out = "## README Metrics\n\n"
  out = out + "- Lines: " + self.line_count.to_string() + "\n"
  out = out + "- Headings: " + self.heading_count.to_string() + "\n"
  out = out + "- Code blocks: " + self.code_block_count.to_string() + "\n"
  out = out + "- Commands: " + self.command_count.to_string() + "\n"
  out = out + "- Links: " + self.link_count.to_string() + "\n"
  out = out + "- Bullets: " + self.bullet_count.to_string() + "\n"
  out = out + "- Coverage score: " + self.coverage_score().to_string() + "\n\n"
  out = out + "### Sections\n\n"
  let mut index = 0
  while index < self.sections.length() {
    let section = self.sections[index]
    out = out + "- L" + section.line.to_string()
    out = out + " H" + section.level.to_string()
    out = out + " " + section.title
    out = out + " (" + section.body_lines.to_string() + " body lines)\n"
    index += 1
  }
  out
}

///|
fn collect_sections(lines : Array[String]) -> Array[SectionInfo] {
  let sections : Array[SectionInfo] = []
  let mut index = 0
  while index < lines.length() {
    let line = lines[index]
    if is_heading_line(line) {
      let level = heading_level(line)
      let title = heading_text(line)
      let body_lines = count_section_body(lines, index, level)
      sections.push(section_info(title, level, index + 1, body_lines))
    }
    index += 1
  }
  sections
}

///|
fn count_section_body(lines : Array[String], start : Int, level : Int) -> Int {
  let mut count = 0
  let mut index = start + 1
  while index < lines.length() {
    if is_heading_line(lines[index]) && heading_level(lines[index]) <= level {
      return count
    }
    if trim_ascii(lines[index]).length() > 0 {
      count += 1
    }
    index += 1
  }
  count
}

///|
fn readme_has_installation(readme : String) -> Bool {
  contains(readme, "安装") ||
  contains_word(readme, "installation") ||
  contains_word(readme, "install") ||
  contains_word(readme, "moon add")
}

///|
fn readme_has_usage(readme : String) -> Bool {
  contains(readme, "使用") ||
  contains(readme, "用法") ||
  contains_word(readme, "usage") ||
  contains_word(readme, "api")
}

///|
fn readme_has_example(readme : String) -> Bool {
  contains(readme, "示例") ||
  contains_word(readme, "example") ||
  contains_word(readme, "moon run")
}

///|
fn readme_has_validation(readme : String) -> Bool {
  contains(readme, "验收") ||
  contains(readme, "测试") ||
  contains_word(readme, "validation") ||
  contains_word(readme, "moon test") ||
  contains_word(readme, "moon check")
}

///|
fn readme_has_license(readme : String) -> Bool {
  contains(readme, "许可证") ||
  contains_word(readme, "license") ||
  contains_word(readme, "MIT") ||
  contains_word(readme, "Apache")
}

///|
fn readme_has_support_scope(readme : String) -> Bool {
  contains(readme, "支持范围") ||
  contains_word(readme, "support scope") ||
  contains_word(readme, "supported")
}

///|
fn readme_has_unsupported_scope(readme : String) -> Bool {
  contains(readme, "暂不支持") ||
  contains(readme, "不支持") ||
  contains_word(readme, "unsupported") ||
  contains_word(readme, "not support")
}

///|
pub fn readme_topic_table(metrics : ReadmeMetrics) -> String {
  let mut out = "| Topic | Present |\n| --- | --- |\n"
  out = out + topic_row("installation", metrics.has_installation)
  out = out + topic_row("usage", metrics.has_usage)
  out = out + topic_row("example", metrics.has_example)
  out = out + topic_row("validation", metrics.has_validation)
  out = out + topic_row("license", metrics.has_license)
  out = out + topic_row("support scope", metrics.has_support_scope)
  out = out + topic_row("unsupported scope", metrics.has_unsupported_scope)
  out
}

///|
fn topic_row(name : String, present : Bool) -> String {
  let status = if present { "yes" } else { "no" }
  "| " + name + " | " + status + " |\n"
}

///|
pub fn longest_section_title(metrics : ReadmeMetrics) -> String {
  let mut best = ""
  let mut best_size = -1
  let mut index = 0
  while index < metrics.sections.length() {
    let section = metrics.sections[index]
    if section.body_lines > best_size {
      best = section.title
      best_size = section.body_lines
    }
    index += 1
  }
  best
}
