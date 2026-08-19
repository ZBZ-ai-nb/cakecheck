///|
pub fn analyze_workflow(text : String) -> WorkflowInfo {
  let lines = split_lines(text)
  let commands : Array[WorkflowCommand] = []
  let targets : Array[String] = []
  let mut has_checkout = false
  let mut has_moon_install = false
  let mut has_check = false
  let mut has_build = false
  let mut has_test = false
  let mut has_run = false
  let mut has_dry_run = false
  let mut command_count = 0
  let mut moon_command_count = 0
  let mut current_name = ""
  let mut index = 0
  while index < lines.length() {
    let raw = lines[index]
    let line = trim_ascii(raw)
    let lower = ascii_lower(line)
    if starts_with(lower, "- name:") || starts_with(lower, "name:") {
      current_name = trim_ascii(
        slice(line, index_of(line, ":").unwrap() + 1, line.length()),
      )
    }
    if contains(lower, "actions/checkout") {
      has_checkout = true
    }
    if contains(lower, "cli.moonbitlang.com") || contains(lower, "moon version") {
      has_moon_install = true
    }
    if starts_with(lower, "run:") || starts_with(lower, "- run:") {
      let command = workflow_command_text(line)
      commands.push(workflow_command(current_name, command, index + 1))
      command_count += 1
      let command_lower = ascii_lower(command)
      if starts_with(command_lower, "moon ") ||
        contains(command_lower, "\nmoon ") {
        moon_command_count += 1
      }
      update_workflow_flags(command_lower, targets)
      if contains(command_lower, "moon check") {
        has_check = true
      }
      if contains(command_lower, "moon build") {
        has_build = true
      }
      if contains(command_lower, "moon test") {
        has_test = true
      }
      if contains(command_lower, "moon run") {
        has_run = true
      }
      if contains(command_lower, "moon publish --dry-run") {
        has_dry_run = true
      }
    } else if is_command_line(line) {
      commands.push(workflow_command(current_name, line, index + 1))
      command_count += 1
      let lower_command = ascii_lower(line)
      if starts_with(lower_command, "moon ") {
        moon_command_count += 1
      }
      update_workflow_flags(lower_command, targets)
      if contains(lower_command, "moon check") {
        has_check = true
      }
      if contains(lower_command, "moon build") {
        has_build = true
      }
      if contains(lower_command, "moon test") {
        has_test = true
      }
      if contains(lower_command, "moon run") {
        has_run = true
      }
      if contains(lower_command, "moon publish --dry-run") {
        has_dry_run = true
      }
    }
    index += 1
  }
  workflow_info(
    command_count, moon_command_count, has_checkout, has_moon_install, has_check,
    has_build, has_test, has_run, has_dry_run, targets, commands,
  )
}

///|
pub fn WorkflowInfo::coverage_score(self : WorkflowInfo) -> Int {
  let mut score = 0
  if self.has_checkout {
    score += 10
  }
  if self.has_moon_install {
    score += 20
  }
  if self.has_check {
    score += 15
  }
  if self.has_build {
    score += 15
  }
  if self.has_test {
    score += 20
  }
  if self.has_run {
    score += 10
  }
  if self.targets.length() > 0 {
    score += 5
  }
  if self.has_publish_dry_run {
    score += 5
  }
  score
}

///|
pub fn WorkflowInfo::is_acceptance_ready(self : WorkflowInfo) -> Bool {
  self.has_moon_install &&
  self.has_check &&
  self.has_build &&
  self.has_test &&
  self.has_run
}

///|
pub fn WorkflowInfo::missing_commands(self : WorkflowInfo) -> Array[String] {
  let missing : Array[String] = []
  if !self.has_moon_install {
    missing.push("install MoonBit")
  }
  if !self.has_check {
    missing.push("moon check")
  }
  if !self.has_build {
    missing.push("moon build")
  }
  if !self.has_test {
    missing.push("moon test")
  }
  if !self.has_run {
    missing.push("moon run")
  }
  missing
}

///|
pub fn WorkflowInfo::summary(self : WorkflowInfo) -> String {
  "ci commands=\{self.command_count}, moon=\{self.moon_command_count}, score=\{self.coverage_score()}"
}

///|
pub fn WorkflowInfo::to_markdown(self : WorkflowInfo) -> String {
  let mut out = "## CI Workflow Metrics\n\n"
  out = out + "- Commands: " + self.command_count.to_string() + "\n"
  out = out + "- Moon commands: " + self.moon_command_count.to_string() + "\n"
  out = out + "- Coverage score: " + self.coverage_score().to_string() + "\n"
  out = out +
    "- Acceptance ready: " +
    bool_text(self.is_acceptance_ready()) +
    "\n\n"
  out = out + "### Commands\n\n"
  let mut index = 0
  while index < self.commands.length() {
    let command = self.commands[index]
    out = out + "- L" + command.line.to_string()
    if command.name.length() > 0 {
      out = out + " " + command.name + ": "
    } else {
      out = out + " "
    }
    out = out + "`" + command.command + "`\n"
    index += 1
  }
  out
}

///|
fn workflow_command_text(line : String) -> String {
  match index_of(line, "run:") {
    None => trim_ascii(line)
    Some(pos) => trim_ascii(slice(line, pos + 4, line.length()))
  }
}

///|
fn update_workflow_flags(command : String, targets : Array[String]) -> Unit {
  if contains(command, "--target wasm") && !target_seen(targets, "wasm") {
    targets.push("wasm")
  }
  if contains(command, "--target js") && !target_seen(targets, "js") {
    targets.push("js")
  }
  if contains(command, "--target native") && !target_seen(targets, "native") {
    targets.push("native")
  }
  if contains(command, "--target all") && !target_seen(targets, "all") {
    targets.push("all")
  }
}

///|
fn target_seen(targets : Array[String], name : String) -> Bool {
  let mut index = 0
  while index < targets.length() {
    if targets[index] == name {
      return true
    }
    index += 1
  }
  false
}

///|
fn bool_text(value : Bool) -> String {
  if value {
    "yes"
  } else {
    "no"
  }
}

///|
pub fn workflow_command_table(info : WorkflowInfo) -> String {
  let mut out = "| Line | Step | Command |\n| --- | --- | --- |\n"
  let mut index = 0
  while index < info.commands.length() {
    let command = info.commands[index]
    out = out + "| " + command.line.to_string()
    out = out + " | " + command.name
    out = out + " | `" + command.command + "` |\n"
    index += 1
  }
  out
}

///|
pub fn workflow_acceptance_label(info : WorkflowInfo) -> String {
  if info.is_acceptance_ready() {
    "ready"
  } else if info.has_check && info.has_test {
    "partial"
  } else {
    "incomplete"
  }
}
