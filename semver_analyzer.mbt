///|
pub fn parse_semver(value : String) -> SemVerInfo {
  let text = trim_ascii(value)
  let build_parts = semver_split_once(text, "+")
  let core_and_pre = build_parts[0]
  let build_metadata : String? = if build_parts.length() == 2 &&
    build_parts[1].length() > 0 {
    Some(build_parts[1])
  } else {
    None
  }
  let pre_parts = semver_split_once(core_and_pre, "-")
  let core = pre_parts[0]
  let pre_release : String? = if pre_parts.length() == 2 &&
    pre_parts[1].length() > 0 {
    Some(pre_parts[1])
  } else {
    None
  }
  let parts = semver_split_char(core, 46)
  if parts.length() != 3 {
    return semver_info(false, 0, 0, 0, pre_release, build_metadata)
  }
  if !semver_numeric_identifier(parts[0]) ||
    !semver_numeric_identifier(parts[1]) ||
    !semver_numeric_identifier(parts[2]) {
    return semver_info(false, 0, 0, 0, pre_release, build_metadata)
  }
  if !semver_optional_identifiers(pre_release) ||
    !semver_optional_identifiers(build_metadata) {
    return semver_info(false, 0, 0, 0, pre_release, build_metadata)
  }
  semver_info(
    true,
    semver_to_int(parts[0]),
    semver_to_int(parts[1]),
    semver_to_int(parts[2]),
    pre_release,
    build_metadata,
  )
}

///|
pub fn SemVerInfo::core(self : SemVerInfo) -> String {
  self.major.to_string() +
  "." +
  self.minor.to_string() +
  "." +
  self.patch.to_string()
}

///|
pub fn SemVerInfo::format(self : SemVerInfo) -> String {
  if !self.valid {
    return "<invalid>"
  }
  let mut out = self.core()
  match self.pre_release {
    None => ()
    Some(pre) => out = out + "-" + pre
  }
  match self.build_metadata {
    None => ()
    Some(build) => out = out + "+" + build
  }
  out
}

///|
pub fn SemVerInfo::is_prerelease(self : SemVerInfo) -> Bool {
  match self.pre_release {
    Some(value) => value.length() > 0
    None => false
  }
}

///|
pub fn SemVerInfo::has_build_metadata(self : SemVerInfo) -> Bool {
  match self.build_metadata {
    Some(value) => value.length() > 0
    None => false
  }
}

///|
pub fn SemVerInfo::is_stable(self : SemVerInfo) -> Bool {
  self.valid && self.major > 0 && !self.is_prerelease()
}

///|
pub fn SemVerInfo::release_channel(self : SemVerInfo) -> String {
  if !self.valid {
    "invalid"
  } else if self.is_prerelease() {
    "prerelease"
  } else if self.major == 0 {
    "initial-development"
  } else {
    "stable"
  }
}

///|
pub fn SemVerInfo::acceptance_note(self : SemVerInfo) -> String {
  if !self.valid {
    "version is not a valid semantic version"
  } else if self.is_prerelease() {
    "pre-release versions are useful for testing but final Mooncakes publication should use a release tag when possible"
  } else if self.major == 0 {
    "0.x versions are acceptable for new libraries, but keep the API boundary clear in README"
  } else {
    "stable semantic version"
  }
}

///|
pub fn SemVerInfo::to_markdown(self : SemVerInfo) -> String {
  let mut out = "## Version Analysis\n\n"
  out = out + "- Version: `" + self.format() + "`\n"
  out = out + "- Valid: " + bool_text(self.valid) + "\n"
  out = out + "- Core: `" + self.core() + "`\n"
  out = out + "- Channel: " + self.release_channel() + "\n"
  out = out + "- Pre-release: " + semver_option_text(self.pre_release) + "\n"
  out = out +
    "- Build metadata: " +
    semver_option_text(self.build_metadata) +
    "\n"
  out = out + "- Note: " + self.acceptance_note() + "\n"
  out
}

///|
pub fn compare_semver(left : String, right : String) -> Int {
  parse_semver(left).compare(parse_semver(right))
}

///|
pub fn SemVerInfo::compare(self : SemVerInfo, other : SemVerInfo) -> Int {
  if !self.valid && !other.valid {
    return 0
  }
  if !self.valid {
    return -1
  }
  if !other.valid {
    return 1
  }
  if self.major != other.major {
    return semver_compare_int(self.major, other.major)
  }
  if self.minor != other.minor {
    return semver_compare_int(self.minor, other.minor)
  }
  if self.patch != other.patch {
    return semver_compare_int(self.patch, other.patch)
  }
  semver_compare_prerelease(self.pre_release, other.pre_release)
}

///|
pub fn classify_version_bump(before : String, after : String) -> VersionBump {
  let left = parse_semver(before)
  let right = parse_semver(after)
  if !left.valid || !right.valid {
    return InvalidVersion
  }
  if left.compare(right) == 0 {
    return SameVersion
  }
  if right.major > left.major {
    Major
  } else if right.major == left.major && right.minor > left.minor {
    Minor
  } else if right.major == left.major &&
    right.minor == left.minor &&
    right.patch > left.patch {
    Patch
  } else {
    InvalidVersion
  }
}

///|
pub fn version_bump_name(bump : VersionBump) -> String {
  match bump {
    Major => "major"
    Minor => "minor"
    Patch => "patch"
    SameVersion => "same"
    InvalidVersion => "invalid"
  }
}

///|
pub fn SemVerInfo::next_patch(self : SemVerInfo) -> String {
  if !self.valid {
    "0.1.0"
  } else {
    self.major.to_string() +
    "." +
    self.minor.to_string() +
    "." +
    (self.patch + 1).to_string()
  }
}

///|
pub fn SemVerInfo::next_minor(self : SemVerInfo) -> String {
  if !self.valid {
    "0.1.0"
  } else {
    self.major.to_string() + "." + (self.minor + 1).to_string() + ".0"
  }
}

///|
pub fn SemVerInfo::next_major(self : SemVerInfo) -> String {
  if !self.valid {
    "1.0.0"
  } else {
    (self.major + 1).to_string() + ".0.0"
  }
}

///|
pub fn recommend_release_version(
  current : String,
  bump : VersionBump,
) -> String {
  let info = parse_semver(current)
  match bump {
    Major => info.next_major()
    Minor => info.next_minor()
    Patch => info.next_patch()
    SameVersion => info.format()
    InvalidVersion => if info.valid { info.next_patch() } else { "0.1.0" }
  }
}

///|
pub fn semver_accepts_mooncakes_release(version : String) -> Bool {
  let info = parse_semver(version)
  info.valid && !info.is_prerelease()
}

///|
pub fn semver_release_table(versions : Array[String]) -> String {
  let mut out = "| Version | Valid | Channel | Next patch |\n| --- | --- | --- | --- |\n"
  let mut index = 0
  while index < versions.length() {
    let info = parse_semver(versions[index])
    out = out + "| `" + versions[index] + "`"
    out = out + " | " + bool_text(info.valid)
    out = out + " | " + info.release_channel()
    out = out + " | `" + info.next_patch() + "` |\n"
    index += 1
  }
  out
}

///|
fn semver_split_once(value : String, marker : String) -> Array[String] {
  let parts : Array[String] = []
  match index_of(value, marker) {
    None => parts.push(value)
    Some(pos) => {
      parts.push(slice(value, 0, pos))
      parts.push(slice(value, pos + marker.length(), value.length()))
    }
  }
  parts
}

///|
fn semver_split_char(value : String, code : Int) -> Array[String] {
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
fn semver_numeric_identifier(value : String) -> Bool {
  if value.length() == 0 {
    return false
  }
  if value.length() > 1 && code_at(value, 0) == 48 {
    return false
  }
  semver_all_digits(value)
}

///|
fn semver_all_digits(value : String) -> Bool {
  let mut index = 0
  while index < value.length() {
    if !is_digit(code_at(value, index)) {
      return false
    }
    index += 1
  }
  true
}

///|
fn semver_optional_identifiers(value : String?) -> Bool {
  match value {
    None => true
    Some(text) => semver_identifier_list(text)
  }
}

///|
fn semver_identifier_list(value : String) -> Bool {
  if value.length() == 0 {
    return false
  }
  let parts = semver_split_char(value, 46)
  let mut index = 0
  while index < parts.length() {
    if !semver_identifier(parts[index]) {
      return false
    }
    index += 1
  }
  true
}

///|
fn semver_identifier(value : String) -> Bool {
  if value.length() == 0 {
    return false
  }
  let mut index = 0
  while index < value.length() {
    let code = code_at(value, index)
    if !(is_ident_char(code) || code == 46) {
      return false
    }
    index += 1
  }
  true
}

///|
fn semver_to_int(value : String) -> Int {
  let mut total = 0
  let mut index = 0
  while index < value.length() {
    total = total * 10 + code_at(value, index) - 48
    index += 1
  }
  total
}

///|
fn semver_compare_int(left : Int, right : Int) -> Int {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn semver_compare_prerelease(left : String?, right : String?) -> Int {
  match left {
    None =>
      match right {
        None => 0
        Some(_) => 1
      }
    Some(left_text) =>
      match right {
        None => -1
        Some(right_text) =>
          semver_compare_identifier_lists(left_text, right_text)
      }
  }
}

///|
fn semver_compare_identifier_lists(left : String, right : String) -> Int {
  let left_parts = semver_split_char(left, 46)
  let right_parts = semver_split_char(right, 46)
  let mut index = 0
  while index < left_parts.length() && index < right_parts.length() {
    let result = semver_compare_identifier_value(
      left_parts[index],
      right_parts[index],
    )
    if result != 0 {
      return result
    }
    index += 1
  }
  semver_compare_int(left_parts.length(), right_parts.length())
}

///|
fn semver_compare_identifier_value(left : String, right : String) -> Int {
  let left_numeric = semver_all_digits(left)
  let right_numeric = semver_all_digits(right)
  if left_numeric && right_numeric {
    return semver_compare_int(semver_to_int(left), semver_to_int(right))
  }
  if left_numeric {
    return -1
  }
  if right_numeric {
    return 1
  }
  semver_compare_ascii(left, right)
}

///|
fn semver_compare_ascii(left : String, right : String) -> Int {
  let mut index = 0
  while index < left.length() && index < right.length() {
    let left_code = code_at(left, index)
    let right_code = code_at(right, index)
    if left_code != right_code {
      return semver_compare_int(left_code, right_code)
    }
    index += 1
  }
  semver_compare_int(left.length(), right.length())
}

///|
fn semver_option_text(value : String?) -> String {
  match value {
    None => "(none)"
    Some(text) => "`" + text + "`"
  }
}
