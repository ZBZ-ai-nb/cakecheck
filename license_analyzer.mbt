///|
pub fn analyze_license(text : String) -> LicenseFacts {
  let lower = ascii_lower(text)
  let family = detect_license_family(lower)
  let spdx = license_spdx(family)
  let osi = license_is_osi(family)
  license_facts(
    family,
    spdx,
    osi,
    contains(lower, "copyright"),
    contains(lower, "permission is hereby granted") ||
    contains(lower, "licensed under the apache license"),
    contains(lower, "without warranty") || contains(lower, "as is"),
    contains(lower, "patent") || family == Apache2,
  )
}

///|
pub fn LicenseFacts::summary(self : LicenseFacts) -> String {
  "license=\{self.spdx_id}, osi=\{bool_text(self.osi_approved)}, copyright=\{bool_text(self.has_copyright)}"
}

///|
pub fn LicenseFacts::completeness_score(self : LicenseFacts) -> Int {
  let mut score = 0
  if self.osi_approved {
    score += 35
  }
  if self.has_copyright {
    score += 20
  }
  if self.has_permission_grant {
    score += 20
  }
  if self.has_warranty_disclaimer {
    score += 20
  }
  if self.has_patent_grant {
    score += 5
  }
  score
}

///|
pub fn LicenseFacts::is_publishable(self : LicenseFacts) -> Bool {
  self.osi_approved && self.has_permission_grant && self.has_warranty_disclaimer
}

///|
pub fn LicenseFacts::to_markdown(self : LicenseFacts) -> String {
  let mut out = "## License Facts\n\n"
  out = out + "- SPDX: " + self.spdx_id + "\n"
  out = out + "- OSI approved: " + bool_text(self.osi_approved) + "\n"
  out = out + "- Has copyright: " + bool_text(self.has_copyright) + "\n"
  out = out +
    "- Has permission grant: " +
    bool_text(self.has_permission_grant) +
    "\n"
  out = out +
    "- Has warranty disclaimer: " +
    bool_text(self.has_warranty_disclaimer) +
    "\n"
  out = out + "- Has patent grant: " + bool_text(self.has_patent_grant) + "\n"
  out = out +
    "- Completeness score: " +
    self.completeness_score().to_string() +
    "\n"
  out
}

///|
fn detect_license_family(lower : String) -> LicenseFamily {
  if contains(lower, "mit license") &&
    contains(lower, "permission is hereby granted") {
    MIT
  } else if contains(lower, "apache license") && contains(lower, "version 2.0") {
    Apache2
  } else if contains(lower, "mozilla public license") && contains(lower, "2.0") {
    MPL2
  } else if contains(lower, "redistribution and use in source and binary forms") &&
    contains(lower, "neither the name") {
    BSD3
  } else if contains(lower, "redistribution and use in source and binary forms") {
    BSD2
  } else {
    UnknownLicense
  }
}

///|
fn license_spdx(family : LicenseFamily) -> String {
  match family {
    MIT => "MIT"
    Apache2 => "Apache-2.0"
    BSD2 => "BSD-2-Clause"
    BSD3 => "BSD-3-Clause"
    MPL2 => "MPL-2.0"
    UnknownLicense => "UNKNOWN"
  }
}

///|
fn license_is_osi(family : LicenseFamily) -> Bool {
  match family {
    MIT => true
    Apache2 => true
    BSD2 => true
    BSD3 => true
    MPL2 => true
    UnknownLicense => false
  }
}

///|
pub fn license_family_name(family : LicenseFamily) -> String {
  match family {
    MIT => "MIT"
    Apache2 => "Apache-2.0"
    BSD2 => "BSD-2-Clause"
    BSD3 => "BSD-3-Clause"
    MPL2 => "MPL-2.0"
    UnknownLicense => "unknown"
  }
}

///|
pub fn license_notice_template(
  project : String,
  holder : String,
  year : Int,
) -> String {
  "Copyright (c) " +
  year.to_string() +
  " " +
  holder +
  "\n\n" +
  project +
  " is distributed under the MIT License."
}

///|
pub fn license_compatibility_note(
  project : LicenseFacts,
  dependency : LicenseFacts,
) -> String {
  if !project.osi_approved || !dependency.osi_approved {
    "manual license review required"
  } else if project.family == MIT {
    "compatible for common open source redistribution"
  } else if project.family == Apache2 && dependency.family == MIT {
    "compatible, keep MIT notice for the dependency"
  } else if project.family == MIT && dependency.family == Apache2 {
    "compatible in many cases, check patent and notice obligations"
  } else {
    "likely compatible, keep original notices"
  }
}
