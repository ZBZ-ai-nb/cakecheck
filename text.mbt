///|
fn code_at(text : String, index : Int) -> Int {
  text[index].to_int()
}

///|
fn slice(text : String, start : Int, end : Int) -> String {
  text[start:end].to_owned()
}

///|
fn is_ascii_space(code : Int) -> Bool {
  code == 32 || code == 9 || code == 10 || code == 13
}

///|
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

///|
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

///|
fn starts_with(text : String, prefix : String) -> Bool {
  prefix.length() <= text.length() && slice(text, 0, prefix.length()) == prefix
}

///|
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

///|
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

///|
fn ascii_lower(text : String) -> String {
  let mut out = ""
  let mut index = 0
  while index < text.length() {
    out = out +
      ascii_lower_piece(code_at(text, index), slice(text, index, index + 1))
    index += 1
  }
  out
}

///|
fn is_digit(code : Int) -> Bool {
  code >= 48 && code <= 57
}

///|
fn parse_int(value : String, fallback : Int) -> Int {
  let text = trim_ascii(value)
  if text.length() == 0 {
    return fallback
  }
  let mut index = 0
  let mut sign = 1
  if code_at(text, 0) == 45 {
    sign = -1
    index = 1
  }
  let mut result = 0
  if index == text.length() {
    return fallback
  }
  while index < text.length() {
    let code = code_at(text, index)
    if !is_digit(code) {
      return fallback
    }
    result = result * 10 + code - 48
    index += 1
  }
  result * sign
}

///|
fn parse_bool(value : String, fallback : Bool) -> Bool {
  match ascii_lower(trim_ascii(value)) {
    "true" => true
    "yes" => true
    "1" => true
    "false" => false
    "no" => false
    "0" => false
    _ => fallback
  }
}

///|
fn split_csv(value : String) -> Array[String] {
  let result : Array[String] = []
  let mut start = 0
  let mut index = 0
  while index <= value.length() {
    if index == value.length() || code_at(value, index) == 44 {
      let item = trim_ascii(slice(value, start, index))
      if item.length() > 0 {
        result.push(item)
      }
      start = index + 1
    }
    index += 1
  }
  result
}

///|
fn split_words_quoted(text : String) -> Array[String] {
  let result : Array[String] = []
  let mut current = ""
  let mut quoted = false
  let mut escaped = false
  let mut index = 0
  while index < text.length() {
    let code = code_at(text, index)
    if escaped {
      current = current + slice(text, index, index + 1)
      escaped = false
    } else if quoted && code == 92 {
      escaped = true
    } else if code == 34 {
      quoted = !quoted
    } else if !quoted && is_ascii_space(code) {
      if current.length() > 0 {
        result.push(current)
        current = ""
      }
    } else {
      current = current + slice(text, index, index + 1)
    }
    index += 1
  }
  if escaped {
    current = current + "\\"
  }
  if current.length() > 0 {
    result.push(current)
  }
  result
}

///|
fn token_value(tokens : Array[String], key : String) -> String? {
  let prefix = key + "="
  let mut index = 0
  while index < tokens.length() {
    if starts_with(tokens[index], prefix) {
      return Some(slice(tokens[index], prefix.length(), tokens[index].length()))
    }
    index += 1
  }
  None
}

///|
fn bool_text(value : Bool) -> String {
  if value {
    "true"
  } else {
    "false"
  }
}

///|
fn json_escape(value : String) -> String {
  let mut out = ""
  let mut index = 0
  while index < value.length() {
    let code = code_at(value, index)
    if code == 34 {
      out = out + "\\\""
    } else if code == 92 {
      out = out + "\\\\"
    } else if code == 10 {
      out = out + "\\n"
    } else if code == 13 {
      out = out + "\\r"
    } else if code == 9 {
      out = out + "\\t"
    } else {
      out = out + slice(value, index, index + 1)
    }
    index += 1
  }
  out
}

///|
fn is_valid_identifier(value : String) -> Bool {
  if value.length() == 0 {
    return false
  }
  let first = code_at(value, 0)
  if !((first >= 65 && first <= 90) ||
    (first >= 97 && first <= 122) ||
    first == 95) {
    return false
  }
  let mut index = 1
  while index < value.length() {
    let code = code_at(value, index)
    if !((code >= 65 && code <= 90) ||
      (code >= 97 && code <= 122) ||
      (code >= 48 && code <= 57) ||
      code == 95 ||
      code == 45) {
      return false
    }
    index += 1
  }
  true
}
