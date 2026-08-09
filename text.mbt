fn code_at(text : String, index : Int) -> Int {
  text[index].to_int()
}

fn slice(text : String, start : Int, end : Int) -> String {
  text[start:end].to_owned()
}

fn is_ascii_space(code : Int) -> Bool {
  code == 32 || code == 9 || code == 10 || code == 13
}

fn trim_ascii(text : String) -> String {
  let mut start = 0
  let mut end = text.length()
  while start < end && is_ascii_space(code_at(text, start)) {
    start += 1
  }
  while end > start && is_ascii_space(code_at(text, end - 1)) {
    end -= 1
  }
  slice(text, start, end)
}

fn split_lines(text : String) -> Array[String] {
  let lines : Array[String] = []
  let mut start = 0
  let mut index = 0
  while index < text.length() {
    if code_at(text, index) == 10 {
      let mut end = index
      if end > start && code_at(text, end - 1) == 13 {
        end -= 1
      }
      lines.push(slice(text, start, end))
      start = index + 1
    }
    index += 1
  }
  if start <= text.length() {
    let mut end = text.length()
    if end > start && code_at(text, end - 1) == 13 {
      end -= 1
    }
    lines.push(slice(text, start, end))
  }
  lines
}

fn starts_with(text : String, prefix : String) -> Bool {
  prefix.length() <= text.length() && slice(text, 0, prefix.length()) == prefix
}

fn ends_with(text : String, suffix : String) -> Bool {
  suffix.length() <= text.length() &&
  slice(text, text.length() - suffix.length(), text.length()) == suffix
}

fn contains(text : String, needle : String) -> Bool {
  if needle.length() == 0 {
    return true
  }
  if needle.length() > text.length() {
    return false
  }
  let limit = text.length() - needle.length()
  let mut index = 0
  while index <= limit {
    if slice(text, index, index + needle.length()) == needle {
      return true
    }
    index += 1
  }
  false
}

fn index_of(text : String, needle : String) -> Int? {
  if needle.length() == 0 {
    return Some(0)
  }
  if needle.length() > text.length() {
    return None
  }
  let limit = text.length() - needle.length()
  let mut index = 0
  while index <= limit {
    if slice(text, index, index + needle.length()) == needle {
      return Some(index)
    }
    index += 1
  }
  None
}

fn ascii_lower_piece(code : Int, original : String) -> String {
  match code {
    65 => "a"
    66 => "b"
    67 => "c"
    68 => "d"
    69 => "e"
    70 => "f"
    71 => "g"
    72 => "h"
    73 => "i"
    74 => "j"
    75 => "k"
    76 => "l"
    77 => "m"
    78 => "n"
    79 => "o"
    80 => "p"
    81 => "q"
    82 => "r"
    83 => "s"
    84 => "t"
    85 => "u"
    86 => "v"
    87 => "w"
    88 => "x"
    89 => "y"
    90 => "z"
    _ => original
  }
}

fn ascii_lower(text : String) -> String {
  let mut out = ""
  let mut index = 0
  while index < text.length() {
    out = out + ascii_lower_piece(code_at(text, index), slice(text, index, index + 1))
    index += 1
  }
  out
}

fn strip_quotes(text : String) -> String {
  let trimmed = trim_ascii(text)
  if trimmed.length() >= 2 &&
     code_at(trimmed, 0) == 34 &&
     code_at(trimmed, trimmed.length() - 1) == 34 {
    slice(trimmed, 1, trimmed.length() - 1)
  } else {
    trimmed
  }
}

fn is_digit(code : Int) -> Bool {
  code >= 48 && code <= 57
}

fn is_ident_char(code : Int) -> Bool {
  (code >= 97 && code <= 122) ||
  (code >= 65 && code <= 90) ||
  (code >= 48 && code <= 57) ||
  code == 95 ||
  code == 45
}

fn has_placeholder(text : String) -> Bool {
  let lower = ascii_lower(text)
  contains(lower, "your-owner") ||
  contains(lower, "your-github") ||
  contains(lower, "todo") ||
  contains(text, "<待填写>") ||
  contains(text, "<MOONCAKES_OWNER>")
}

fn severity_name(severity : Severity) -> String {
  match severity {
    Pass => "PASS"
    Info => "INFO"
    Warning => "WARN"
    Error => "ERROR"
  }
}

fn category_name(category : Category) -> String {
  match category {
    Manifest => "manifest"
    Readme => "readme"
    CI => "ci"
    License => "license"
    Release => "release"
    Repository => "repository"
  }
}
