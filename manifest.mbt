///|
pub fn parse_manifest(text : String) -> ManifestInfo {
  let fields : Array[ManifestField] = []
  let duplicates : Array[String] = []
  let malformed : Array[Int] = []
  let lines = split_lines(text)
  let mut index = 0
  while index < lines.length() {
    let line_no = index + 1
    let line = trim_ascii(lines[index])
    if line.length() > 0 && !starts_with(line, "//") {
      match index_of(line, "=") {
        None => malformed.push(line_no)
        Some(eq) => {
          let key = trim_ascii(slice(line, 0, eq))
          let value = strip_quotes(slice(line, eq + 1, line.length()))
          if key.length() == 0 {
            malformed.push(line_no)
          } else {
            if manifest_has_key(fields, key) && !array_contains(duplicates, key) {
              duplicates.push(key)
            }
            fields.push(field(key, value, line_no))
          }
        }
      }
    }
    index += 1
  }
  manifest_info(fields, duplicates, malformed)
}

///|
pub fn ManifestInfo::get(self : ManifestInfo, key : String) -> String? {
  let mut index = 0
  while index < self.fields.length() {
    if self.fields[index].key == key {
      return Some(self.fields[index].value)
    }
    index += 1
  }
  None
}

///|
pub fn ManifestInfo::has(self : ManifestInfo, key : String) -> Bool {
  match self.get(key) {
    Some(_) => true
    None => false
  }
}

///|
pub fn ManifestInfo::package_name(self : ManifestInfo) -> String {
  match self.get("name") {
    Some(value) => value
    None => "<missing>"
  }
}

///|
pub fn ManifestInfo::version(self : ManifestInfo) -> String {
  match self.get("version") {
    Some(value) => value
    None => "<missing>"
  }
}

///|
fn manifest_has_key(fields : Array[ManifestField], key : String) -> Bool {
  let mut index = 0
  while index < fields.length() {
    if fields[index].key == key {
      return true
    }
    index += 1
  }
  false
}

///|
fn array_contains(items : Array[String], value : String) -> Bool {
  let mut index = 0
  while index < items.length() {
    if items[index] == value {
      return true
    }
    index += 1
  }
  false
}

///|
fn valid_package_name(value : String) -> Bool {
  match index_of(value, "/") {
    None => false
    Some(pos) =>
      pos > 0 &&
      pos + 1 < value.length() &&
      valid_slug(slice(value, 0, pos)) &&
      valid_slug(slice(value, pos + 1, value.length()))
  }
}

///|
fn valid_slug(value : String) -> Bool {
  if value.length() == 0 {
    return false
  }
  let mut index = 0
  while index < value.length() {
    if !is_ident_char(code_at(value, index)) {
      return false
    }
    index += 1
  }
  true
}

///|
fn valid_semver(value : String) -> Bool {
  let parts = split_dot3(value)
  parts.length() == 3 &&
  all_digits(parts[0]) &&
  all_digits(parts[1]) &&
  all_digits(parts[2])
}

///|
fn split_dot3(value : String) -> Array[String] {
  let parts : Array[String] = []
  let mut start = 0
  let mut index = 0
  while index < value.length() {
    if code_at(value, index) == 46 {
      parts.push(slice(value, start, index))
      start = index + 1
    }
    index += 1
  }
  parts.push(slice(value, start, value.length()))
  parts
}

///|
fn all_digits(value : String) -> Bool {
  if value.length() == 0 {
    return false
  }
  let mut index = 0
  while index < value.length() {
    if !is_digit(code_at(value, index)) {
      return false
    }
    index += 1
  }
  true
}
