///|
pub fn analyze_namespace(raw : String, repository : String) -> NamespaceInfo {
  let name = trim_ascii(raw)
  let parts = namespace_split_char(name, 47)
  let owner = if parts.length() == 2 { parts[0] } else { "" }
  let package_name = if parts.length() == 2 { parts[1] } else { "" }
  let valid = parts.length() == 2 &&
    namespace_valid_segment(owner) &&
    namespace_valid_segment(package_name)
  let repo_parts = github_owner_repo(repository)
  let repo_owner = if repo_parts.length() == 2 { repo_parts[0] } else { "" }
  let repo_name = if repo_parts.length() == 2 { repo_parts[1] } else { "" }
  let owner_matches = repo_owner.length() > 0 &&
    ascii_lower(owner) == ascii_lower(repo_owner)
  let package_matches = repo_name.length() > 0 &&
    ascii_lower(package_name) == ascii_lower(repo_name)
  namespace_info(
    name, owner, package_name, valid, owner_matches, package_matches,
  )
}

///|
pub fn NamespaceInfo::canonical_name(self : NamespaceInfo) -> String {
  if self.valid {
    self.owner + "/" + self.package_name
  } else {
    self.raw
  }
}

///|
pub fn NamespaceInfo::mooncakes_url(self : NamespaceInfo) -> String {
  if self.valid {
    "https://mooncakes.io/docs/" + self.owner + "/" + self.package_name
  } else {
    "https://mooncakes.io/"
  }
}

///|
pub fn NamespaceInfo::github_url(self : NamespaceInfo) -> String {
  if self.valid {
    "https://github.com/" + self.owner + "/" + self.package_name
  } else {
    ""
  }
}

///|
pub fn NamespaceInfo::repository_git_url(self : NamespaceInfo) -> String {
  if self.valid {
    self.github_url() + ".git"
  } else {
    ""
  }
}

///|
pub fn NamespaceInfo::is_publishable(self : NamespaceInfo) -> Bool {
  self.valid && self.owner_matches_github && self.package_matches_repo
}

///|
pub fn NamespaceInfo::risk_level(self : NamespaceInfo) -> String {
  if !self.valid {
    "blocking"
  } else if !self.owner_matches_github {
    "review"
  } else if !self.package_matches_repo {
    "notice"
  } else {
    "ok"
  }
}

///|
pub fn NamespaceInfo::summary(self : NamespaceInfo) -> String {
  "namespace=\{self.canonical_name()}, valid=\{bool_text(self.valid)}, owner-match=\{bool_text(self.owner_matches_github)}, repo-match=\{bool_text(self.package_matches_repo)}"
}

///|
pub fn NamespaceInfo::recommendation(self : NamespaceInfo) -> String {
  if !self.valid {
    "Use the Mooncakes namespace format owner/package in moon.mod."
  } else if !self.owner_matches_github {
    "Confirm the Mooncakes owner is controlled by the same GitHub account or organization."
  } else if !self.package_matches_repo {
    "Package and repository names differ; document the reason or align them before release."
  } else {
    "Namespace and GitHub repository are aligned."
  }
}

///|
pub fn NamespaceInfo::to_markdown(self : NamespaceInfo) -> String {
  let mut out = "## Namespace Analysis\n\n"
  out = out + "- Raw name: `" + self.raw + "`\n"
  out = out + "- Owner: `" + self.owner + "`\n"
  out = out + "- Package: `" + self.package_name + "`\n"
  out = out + "- Valid: " + bool_text(self.valid) + "\n"
  out = out +
    "- Owner matches GitHub: " +
    bool_text(self.owner_matches_github) +
    "\n"
  out = out +
    "- Repository name matches package: " +
    bool_text(self.package_matches_repo) +
    "\n"
  out = out + "- Mooncakes URL: " + self.mooncakes_url() + "\n"
  out = out + "- Risk: " + self.risk_level() + "\n"
  out = out + "- Recommendation: " + self.recommendation() + "\n"
  out
}

///|
pub fn github_owner_repo(repository : String) -> Array[String] {
  let value = namespace_clean_repository(repository)
  if starts_with(value, "https://github.com/") {
    return namespace_owner_repo_tail(slice(value, 19, value.length()))
  }
  if starts_with(value, "http://github.com/") {
    return namespace_owner_repo_tail(slice(value, 18, value.length()))
  }
  if starts_with(value, "git@github.com:") {
    return namespace_owner_repo_tail(slice(value, 15, value.length()))
  }
  []
}

///|
pub fn namespace_alignment_table(items : Array[NamespaceInfo]) -> String {
  let mut out = "| Package | Valid | Owner match | Repo match | Risk |\n| --- | --- | --- | --- | --- |\n"
  let mut index = 0
  while index < items.length() {
    let item = items[index]
    out = out + "| `" + item.canonical_name() + "`"
    out = out + " | " + bool_text(item.valid)
    out = out + " | " + bool_text(item.owner_matches_github)
    out = out + " | " + bool_text(item.package_matches_repo)
    out = out + " | " + item.risk_level() + " |\n"
    index += 1
  }
  out
}

///|
pub fn namespace_from_manifest(manifest : ManifestInfo) -> NamespaceInfo {
  let package_name = match manifest.get("name") {
    None => ""
    Some(value) => value
  }
  let repository = match manifest.get("repository") {
    None => ""
    Some(value) => value
  }
  analyze_namespace(package_name, repository)
}

///|
pub fn mooncakes_package_page(package_name : String) -> String {
  let info = analyze_namespace(package_name, "")
  info.mooncakes_url()
}

///|
pub fn package_name_from_repository(repository : String) -> String {
  let parts = github_owner_repo(repository)
  if parts.length() == 2 {
    parts[0] + "/" + parts[1]
  } else {
    ""
  }
}

///|
pub fn suggested_package_name(owner : String, repo : String) -> String {
  namespace_slug(owner) + "/" + namespace_slug(repo)
}

///|
pub fn namespace_has_placeholder(name : String) -> Bool {
  has_placeholder(name) ||
  contains_word(name, "owner") ||
  contains_word(name, "username") ||
  contains_word(name, "example")
}

///|
pub fn namespace_acceptance_issue(info : NamespaceInfo) -> String {
  if namespace_has_placeholder(info.raw) {
    "package namespace still looks like a placeholder"
  } else if !info.valid {
    "package namespace is malformed"
  } else if !info.owner_matches_github {
    "Mooncakes owner differs from GitHub owner"
  } else if !info.package_matches_repo {
    "Mooncakes package name differs from repository name"
  } else {
    ""
  }
}

///|
fn namespace_clean_repository(repository : String) -> String {
  let trimmed = trim_ascii(repository)
  if ends_with(trimmed, ".git") {
    slice(trimmed, 0, trimmed.length() - 4)
  } else if ends_with(trimmed, "/") {
    slice(trimmed, 0, trimmed.length() - 1)
  } else {
    trimmed
  }
}

///|
fn namespace_owner_repo_tail(tail : String) -> Array[String] {
  let parts = namespace_split_char(tail, 47)
  if parts.length() >= 2 {
    [parts[0], namespace_strip_git_suffix(parts[1])]
  } else {
    []
  }
}

///|
fn namespace_strip_git_suffix(value : String) -> String {
  if ends_with(value, ".git") {
    slice(value, 0, value.length() - 4)
  } else {
    value
  }
}

///|
fn namespace_split_char(value : String, code : Int) -> Array[String] {
  let parts : Array[String] = []
  let mut start = 0
  let mut index = 0
  while index < value.length() {
    if code_at(value, index) == code {
      parts.push(slice(value, start, index))
      start = index + 1
    }
    index += 1
  }
  parts.push(slice(value, start, value.length()))
  parts
}

///|
fn namespace_valid_segment(value : String) -> Bool {
  if value.length() == 0 {
    return false
  }
  if code_at(value, 0) == 45 || code_at(value, value.length() - 1) == 45 {
    return false
  }
  let mut index = 0
  while index < value.length() {
    let code = code_at(value, index)
    if !is_ident_char(code) {
      return false
    }
    index += 1
  }
  true
}

///|
fn namespace_slug(value : String) -> String {
  let lower = ascii_lower(trim_ascii(value))
  let mut out = ""
  let mut previous_dash = false
  let mut index = 0
  while index < lower.length() {
    let code = code_at(lower, index)
    if is_ident_char(code) && code != 95 {
      out = out + slice(lower, index, index + 1)
      previous_dash = false
    } else if !previous_dash && out.length() > 0 {
      out = out + "-"
      previous_dash = true
    }
    index += 1
  }
  if ends_with(out, "-") {
    slice(out, 0, out.length() - 1)
  } else {
    out
  }
}
