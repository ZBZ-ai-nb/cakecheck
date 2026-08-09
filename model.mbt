pub(all) enum Severity {
  Pass
  Info
  Warning
  Error
} derive(Debug, Eq)

pub(all) enum Category {
  Manifest
  Readme
  CI
  License
  Release
  Repository
} derive(Debug, Eq)

pub(all) enum AuditProfile {
  Quick
  Release
  Hackathon
} derive(Debug, Eq)

pub(all) struct AuditInput {
  moon_mod : String
  readme : String
  ci : String
  license_text : String
  changelog : String
  repository_public : Bool
  commit_count : Int
  package_published : Bool
} derive(Debug, Eq)

pub(all) struct ManifestField {
  key : String
  value : String
  line : Int
} derive(Debug, Eq)

pub(all) struct ManifestInfo {
  fields : Array[ManifestField]
  duplicates : Array[String]
  malformed_lines : Array[Int]
} derive(Debug, Eq)

pub(all) struct AuditCheck {
  category : Category
  severity : Severity
  code : String
  message : String
  hint : String
} derive(Debug, Eq)

pub(all) struct Score {
  pass_count : Int
  info_count : Int
  warning_count : Int
  error_count : Int
  total : Int
  readiness : Int
} derive(Debug, Eq)

pub(all) struct AuditReport {
  package_name : String
  version : String
  checks : Array[AuditCheck]
  score : Score
} derive(Debug, Eq)

pub(all) struct GateResult {
  profile : AuditProfile
  passed : Bool
  message : String
  required_codes : Array[String]
} derive(Debug, Eq)

pub(all) struct AuditDiff {
  before_readiness : Int
  after_readiness : Int
  readiness_delta : Int
  fixed_codes : Array[String]
  new_problem_codes : Array[String]
} derive(Debug, Eq)

fn audit_input(
  moon_mod : String,
  readme : String,
  ci : String,
  license_text : String,
  changelog : String,
  repository_public : Bool,
  commit_count : Int,
  package_published : Bool
) -> AuditInput {
  AuditInput::{
    moon_mod: moon_mod,
    readme: readme,
    ci: ci,
    license_text: license_text,
    changelog: changelog,
    repository_public: repository_public,
    commit_count: commit_count,
    package_published: package_published,
  }
}

fn field(key : String, value : String, line : Int) -> ManifestField {
  ManifestField::{ key: key, value: value, line: line }
}

fn manifest_info(
  fields : Array[ManifestField],
  duplicates : Array[String],
  malformed_lines : Array[Int]
) -> ManifestInfo {
  ManifestInfo::{ fields: fields, duplicates: duplicates, malformed_lines: malformed_lines }
}

fn check(
  category : Category,
  severity : Severity,
  code : String,
  message : String,
  hint : String
) -> AuditCheck {
  AuditCheck::{
    category: category,
    severity: severity,
    code: code,
    message: message,
    hint: hint,
  }
}

fn score(
  pass_count : Int,
  info_count : Int,
  warning_count : Int,
  error_count : Int,
  total : Int,
  readiness : Int
) -> Score {
  Score::{
    pass_count: pass_count,
    info_count: info_count,
    warning_count: warning_count,
    error_count: error_count,
    total: total,
    readiness: readiness,
  }
}

fn audit_report(
  package_name : String,
  version : String,
  checks : Array[AuditCheck],
  score : Score
) -> AuditReport {
  AuditReport::{
    package_name: package_name,
    version: version,
    checks: checks,
    score: score,
  }
}

fn gate_result(
  profile : AuditProfile,
  passed : Bool,
  message : String,
  required_codes : Array[String]
) -> GateResult {
  GateResult::{
    profile: profile,
    passed: passed,
    message: message,
    required_codes: required_codes,
  }
}

fn audit_diff(
  before_readiness : Int,
  after_readiness : Int,
  readiness_delta : Int,
  fixed_codes : Array[String],
  new_problem_codes : Array[String]
) -> AuditDiff {
  AuditDiff::{
    before_readiness: before_readiness,
    after_readiness: after_readiness,
    readiness_delta: readiness_delta,
    fixed_codes: fixed_codes,
    new_problem_codes: new_problem_codes,
  }
}

