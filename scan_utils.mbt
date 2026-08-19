///|
fn is_letter(code : Int) -> Bool {
  (code >= 65 && code <= 90) || (code >= 97 && code <= 122)
}

///|
fn is_digit_char(code : Int) -> Bool {
  code >= 48 && code <= 57
}

///|
fn is_separator_char(code : Int) -> Bool {
  if is_letter(code) || is_digit_char(code) {
    return false
  }
  code == 32 ||
  code == 9 ||
  code == 10 ||
  code == 13 ||
  code == 45 ||
  code == 95 ||
  code == 46 ||
  code == 47 ||
  code == 58 ||
  code == 44 ||
  code == 59 ||
  code == 124 ||
  code == 40 ||
  code == 41 ||
  code == 91 ||
  code == 93 ||
  code == 123 ||
  code == 125 ||
  code == 33 ||
  code == 63
}

///|
fn normalize_text(text : String) -> String {
  ascii_lower(trim_ascii(text))
}

///|
fn normalize_compact(text : String) -> String {
  let lower = normalize_text(text)
  let mut out = ""
  let mut index = 0
  while index < lower.length() {
    let code = code_at(lower, index)
    if is_separator_char(code) {
      if out.length() > 0 && code != 47 {
        let last = code_at(out, out.length() - 1)
        if last != 32 {
          out = out + " "
        }
      } else if code == 47 {
        out = out + "/"
      }
    } else {
      out = out + slice(lower, index, index + 1)
    }
    index += 1
  }
  trim_ascii(out)
}

///|
pub fn contains_word(text : String, word : String) -> Bool {
  let haystack = normalize_compact(text)
  let needle = normalize_compact(word)
  if needle.length() == 0 {
    return true
  }
  if haystack.length() < needle.length() {
    return false
  }
  let mut index = 0
  while index + needle.length() <= haystack.length() {
    if slice(haystack, index, index + needle.length()) == needle {
      let before_ok = index == 0 ||
        is_separator_char(code_at(haystack, index - 1))
      let after_index = index + needle.length()
      let after_ok = after_index == haystack.length() ||
        is_separator_char(code_at(haystack, after_index))
      if before_ok && after_ok {
        return true
      }
    }
    index += 1
  }
  false
}

///|
pub fn count_word(text : String, word : String) -> Int {
  let haystack = normalize_compact(text)
  let needle = normalize_compact(word)
  if needle.length() == 0 || haystack.length() < needle.length() {
    return 0
  }
  let mut count = 0
  let mut index = 0
  while index + needle.length() <= haystack.length() {
    if slice(haystack, index, index + needle.length()) == needle {
      let before_ok = index == 0 ||
        is_separator_char(code_at(haystack, index - 1))
      let after_index = index + needle.length()
      let after_ok = after_index == haystack.length() ||
        is_separator_char(code_at(haystack, after_index))
      if before_ok && after_ok {
        count += 1
        index += needle.length()
      } else {
        index += 1
      }
    } else {
      index += 1
    }
  }
  count
}

///|
pub fn any_match(text : String, items : Array[String]) -> Bool {
  let mut index = 0
  while index < items.length() {
    if contains_word(text, items[index]) {
      return true
    }
    index += 1
  }
  false
}

///|
pub fn all_match(text : String, items : Array[String]) -> Bool {
  let mut index = 0
  while index < items.length() {
    if !contains_word(text, items[index]) {
      return false
    }
    index += 1
  }
  true
}

///|
pub fn is_heading_line(line : String) -> Bool {
  let text = trim_ascii(line)
  text.length() > 0 && code_at(text, 0) == 35
}

///|
pub fn heading_level(line : String) -> Int {
  let text = trim_ascii(line)
  let mut index = 0
  while index < text.length() && code_at(text, index) == 35 {
    index += 1
  }
  index
}

///|
pub fn heading_text(line : String) -> String {
  let text = trim_ascii(line)
  let mut index = 0
  while index < text.length() && code_at(text, index) == 35 {
    index += 1
  }
  trim_ascii(slice(text, index, text.length()))
}

///|
pub fn is_fence_line(line : String) -> Bool {
  let text = trim_ascii(line)
  text.length() >= 3 &&
  code_at(text, 0) == 96 &&
  code_at(text, 1) == 96 &&
  code_at(text, 2) == 96
}

///|
pub fn is_bullet_line(line : String) -> Bool {
  let text = trim_ascii(line)
  text.length() > 1 &&
  (code_at(text, 0) == 45 || code_at(text, 0) == 42) &&
  code_at(text, 1) == 32
}

///|
pub fn is_numbered_line(line : String) -> Bool {
  let text = trim_ascii(line)
  if text.length() < 3 {
    return false
  }
  let first = code_at(text, 0)
  let second = code_at(text, 1)
  let third = code_at(text, 2)
  is_digit_char(first) && second == 46 && third == 32
}

///|
pub fn is_command_line(line : String) -> Bool {
  let text = trim_ascii(line)
  starts_with(text, "moon ") ||
  starts_with(text, "moon\t") ||
  starts_with(text, "git ") ||
  starts_with(text, "curl ") ||
  starts_with(text, "npm ") ||
  starts_with(text, "pnpm ")
}

///|
pub fn is_markdown_link_line(line : String) -> Bool {
  let text = trim_ascii(line)
  contains(text, "](") && contains(text, "http")
}

///|
pub fn is_badge_line(line : String) -> Bool {
  let text = trim_ascii(line)
  contains(text, "shields.io") || contains(text, "badge")
}

///|
pub fn extract_inline_link_target(line : String) -> String? {
  let text = trim_ascii(line)
  match index_of(text, "](") {
    None => None
    Some(start) => {
      let mut index = start + 2
      while index < text.length() {
        if code_at(text, index) == 41 {
          return Some(slice(text, start + 2, index))
        }
        index += 1
      }
      None
    }
  }
}

///|
pub fn extract_inline_link_text(line : String) -> String? {
  let text = trim_ascii(line)
  match index_of(text, "[") {
    None => None
    Some(start) =>
      match index_of(text, "](") {
        None => None
        Some(end) =>
          if end > start {
            Some(slice(text, start + 1, end))
          } else {
            None
          }
      }
  }
}

///|
pub fn split_tokens(text : String) -> Array[String] {
  let tokens : Array[String] = []
  let mut current = ""
  let mut index = 0
  while index < text.length() {
    let code = code_at(text, index)
    if is_separator_char(code) {
      if current.length() > 0 {
        tokens.push(current)
        current = ""
      }
    } else {
      current = current + slice(text, index, index + 1)
    }
    index += 1
  }
  if current.length() > 0 {
    tokens.push(current)
  }
  tokens
}

///|
pub fn first_token(text : String) -> String {
  let tokens = split_tokens(text)
  if tokens.length() == 0 {
    ""
  } else {
    tokens[0]
  }
}

///|
pub fn last_token(text : String) -> String {
  let tokens = split_tokens(text)
  if tokens.length() == 0 {
    ""
  } else {
    tokens[tokens.length() - 1]
  }
}

///|
pub fn remove_trailing_punctuation(text : String) -> String {
  let value = trim_ascii(text)
  let mut end = value.length()
  while end > 0 {
    let code = code_at(value, end - 1)
    if code == 46 ||
      code == 44 ||
      code == 59 ||
      code == 58 ||
      code == 33 ||
      code == 63 {
      end -= 1
    } else {
      break
    }
  }
  trim_ascii(slice(value, 0, end))
}

///|
pub fn canonicalize_token(text : String) -> String {
  normalize_compact(remove_trailing_punctuation(text))
}
