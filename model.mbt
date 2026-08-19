///|
pub(all) enum Severity {
  Pass
  Info
  Warning
  Error
} derive(Debug, Eq)

///|
pub(all) enum Category {
  Manifest
  Readme
  CI
  License
  Release
  Repository
} derive(Debug, Eq)

///|
pub(all) enum AuditProfile {
  Quick
  Release
  Hackathon
} derive(Debug, Eq)

///|
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

///|
pub(all) struct ManifestField {
  key : String
  value : String
  line : Int
} derive(Debug, Eq)

///|
pub(all) struct ManifestInfo {
  fields : Array[ManifestField]
  duplicates : Array[String]
  malformed_lines : Array[Int]
} derive(Debug, Eq)

///|
pub(all) struct AuditCheck {
  category : Category
  severity : Severity
  code : String
  message : String
  hint : String
} derive(Debug, Eq)

///|
pub(all) struct Score {
  pass_count : Int
  info_count : Int
  warning_count : Int
  error_count : Int
  total : Int
  readiness : Int
} derive(Debug, Eq)

///|
pub(all) struct AuditReport {
  package_name : String
  version : String
  checks : Array[AuditCheck]
  score : Score
} derive(Debug, Eq)

///|
pub(all) struct GateResult {
  profile : AuditProfile
  passed : Bool
  message : String
  required_codes : Array[String]
} derive(Debug, Eq)

///|
pub(all) struct AuditDiff {
  before_readiness : Int
  after_readiness : Int
  readiness_delta : Int
  fixed_codes : Array[String]
  new_problem_codes : Array[String]
} derive(Debug, Eq)

///|
pub(all) struct SectionInfo {
  title : String
  level : Int
  line : Int
  body_lines : Int
} derive(Debug, Eq)

///|
pub(all) struct ReadmeMetrics {
  line_count : Int
  heading_count : Int
  code_block_count : Int
  command_count : Int
  link_count : Int
  bullet_count : Int
  has_installation : Bool
  has_usage : Bool
  has_example : Bool
  has_validation : Bool
  has_license : Bool
  has_support_scope : Bool
  has_unsupported_scope : Bool
  sections : Array[SectionInfo]
} derive(Debug, Eq)

///|
pub(all) struct WorkflowCommand {
  name : String
  command : String
  line : Int
} derive(Debug, Eq)

///|
pub(all) struct WorkflowInfo {
  command_count : Int
  moon_command_count : Int
  has_checkout : Bool
  has_moon_install : Bool
  has_check : Bool
  has_build : Bool
  has_test : Bool
  has_run : Bool
  has_publish_dry_run : Bool
  targets : Array[String]
  commands : Array[WorkflowCommand]
} derive(Debug, Eq)

///|
pub(all) enum LicenseFamily {
  MIT
  Apache2
  BSD2
  BSD3
  MPL2
  UnknownLicense
} derive(Debug, Eq)

///|
pub(all) struct LicenseFacts {
  family : LicenseFamily
  spdx_id : String
  osi_approved : Bool
  has_copyright : Bool
  has_permission_grant : Bool
  has_warranty_disclaimer : Bool
  has_patent_grant : Bool
} derive(Debug, Eq)

///|
pub(all) struct SemVerInfo {
  valid : Bool
  major : Int
  minor : Int
  patch : Int
  pre_release : String?
  build_metadata : String?
} derive(Debug, Eq)

///|
pub(all) enum VersionBump {
  Major
  Minor
  Patch
  SameVersion
  InvalidVersion
} derive(Debug, Eq)

///|
pub(all) struct NamespaceInfo {
  raw : String
  owner : String
  package_name : String
  valid : Bool
  owner_matches_github : Bool
  package_matches_repo : Bool
} derive(Debug, Eq)

///|
pub(all) struct EvidenceItem {
  code : String
  label : String
  present : Bool
  source : String
} derive(Debug, Eq)

///|
pub(all) struct EvidenceMatrix {
  items : Array[EvidenceItem]
  present_count : Int
  missing_count : Int
} derive(Debug, Eq)

///|
pub(all) struct ReleaseStep {
  index : Int
  command : String
  required : Bool
  description : String
} derive(Debug, Eq)

///|
pub(all) struct ReleasePlan {
  package_name : String
  version : String
  steps : Array[ReleaseStep]
  blockers : Array[String]
} derive(Debug, Eq)

///|
pub(all) struct QualityAxis {
  name : String
  score : Int
  weight : Int
  note : String
} derive(Debug, Eq)

///|
pub(all) struct QualityMatrix {
  axes : Array[QualityAxis]
  weighted_score : Int
  max_score : Int
  normalized_score : Int
} derive(Debug, Eq)

///|
fn audit_input(
  moon_mod : String,
  readme : String,
  ci : String,
  license_text : String,
  changelog : String,
  repository_public : Bool,
  commit_count : Int,
  package_published : Bool,
) -> AuditInput {
  AuditInput::{
    moon_mod,
    readme,
    ci,
    license_text,
    changelog,
    repository_public,
    commit_count,
    package_published,
  }
}

///|
fn field(key : String, value : String, line : Int) -> ManifestField {
  ManifestField::{ key, value, line }
}

///|
fn manifest_info(
  fields : Array[ManifestField],
  duplicates : Array[String],
  malformed_lines : Array[Int],
) -> ManifestInfo {
  ManifestInfo::{ fields, duplicates, malformed_lines }
}

///|
fn check(
  category : Category,
  severity : Severity,
  code : String,
  message : String,
  hint : String,
) -> AuditCheck {
  AuditCheck::{ category, severity, code, message, hint }
}

///|
fn score(
  pass_count : Int,
  info_count : Int,
  warning_count : Int,
  error_count : Int,
  total : Int,
  readiness : Int,
) -> Score {
  Score::{
    pass_count,
    info_count,
    warning_count,
    error_count,
    total,
    readiness,
  }
}

///|
fn audit_report(
  package_name : String,
  version : String,
  checks : Array[AuditCheck],
  score : Score,
) -> AuditReport {
  AuditReport::{ package_name, version, checks, score }
}

///|
fn gate_result(
  profile : AuditProfile,
  passed : Bool,
  message : String,
  required_codes : Array[String],
) -> GateResult {
  GateResult::{ profile, passed, message, required_codes }
}

///|
fn audit_diff(
  before_readiness : Int,
  after_readiness : Int,
  readiness_delta : Int,
  fixed_codes : Array[String],
  new_problem_codes : Array[String],
) -> AuditDiff {
  AuditDiff::{
    before_readiness,
    after_readiness,
    readiness_delta,
    fixed_codes,
    new_problem_codes,
  }
}

///|
fn section_info(
  title : String,
  level : Int,
  line : Int,
  body_lines : Int,
) -> SectionInfo {
  SectionInfo::{ title, level, line, body_lines }
}

///|
fn readme_metrics(
  line_count : Int,
  heading_count : Int,
  code_block_count : Int,
  command_count : Int,
  link_count : Int,
  bullet_count : Int,
  has_installation : Bool,
  has_usage : Bool,
  has_example : Bool,
  has_validation : Bool,
  has_license : Bool,
  has_support_scope : Bool,
  has_unsupported_scope : Bool,
  sections : Array[SectionInfo],
) -> ReadmeMetrics {
  ReadmeMetrics::{
    line_count,
    heading_count,
    code_block_count,
    command_count,
    link_count,
    bullet_count,
    has_installation,
    has_usage,
    has_example,
    has_validation,
    has_license,
    has_support_scope,
    has_unsupported_scope,
    sections,
  }
}

///|
fn workflow_command(
  name : String,
  command : String,
  line : Int,
) -> WorkflowCommand {
  WorkflowCommand::{ name, command, line }
}

///|
fn workflow_info(
  command_count : Int,
  moon_command_count : Int,
  has_checkout : Bool,
  has_moon_install : Bool,
  has_check : Bool,
  has_build : Bool,
  has_test : Bool,
  has_run : Bool,
  has_publish_dry_run : Bool,
  targets : Array[String],
  commands : Array[WorkflowCommand],
) -> WorkflowInfo {
  WorkflowInfo::{
    command_count,
    moon_command_count,
    has_checkout,
    has_moon_install,
    has_check,
    has_build,
    has_test,
    has_run,
    has_publish_dry_run,
    targets,
    commands,
  }
}

///|
fn license_facts(
  family : LicenseFamily,
  spdx_id : String,
  osi_approved : Bool,
  has_copyright : Bool,
  has_permission_grant : Bool,
  has_warranty_disclaimer : Bool,
  has_patent_grant : Bool,
) -> LicenseFacts {
  LicenseFacts::{
    family,
    spdx_id,
    osi_approved,
    has_copyright,
    has_permission_grant,
    has_warranty_disclaimer,
    has_patent_grant,
  }
}

///|
fn semver_info(
  valid : Bool,
  major : Int,
  minor : Int,
  patch : Int,
  pre_release : String?,
  build_metadata : String?,
) -> SemVerInfo {
  SemVerInfo::{ valid, major, minor, patch, pre_release, build_metadata }
}

///|
fn namespace_info(
  raw : String,
  owner : String,
  package_name : String,
  valid : Bool,
  owner_matches_github : Bool,
  package_matches_repo : Bool,
) -> NamespaceInfo {
  NamespaceInfo::{
    raw,
    owner,
    package_name,
    valid,
    owner_matches_github,
    package_matches_repo,
  }
}

///|
fn evidence_item(
  code : String,
  label : String,
  present : Bool,
  source : String,
) -> EvidenceItem {
  EvidenceItem::{ code, label, present, source }
}

///|
fn evidence_matrix(
  items : Array[EvidenceItem],
  present_count : Int,
  missing_count : Int,
) -> EvidenceMatrix {
  EvidenceMatrix::{ items, present_count, missing_count }
}

///|
fn release_step(
  index : Int,
  command : String,
  required : Bool,
  description : String,
) -> ReleaseStep {
  ReleaseStep::{ index, command, required, description }
}

///|
fn release_plan(
  package_name : String,
  version : String,
  steps : Array[ReleaseStep],
  blockers : Array[String],
) -> ReleasePlan {
  ReleasePlan::{ package_name, version, steps, blockers }
}

///|
fn quality_axis(
  name : String,
  score : Int,
  weight : Int,
  note : String,
) -> QualityAxis {
  QualityAxis::{ name, score, weight, note }
}

///|
fn quality_matrix(
  axes : Array[QualityAxis],
  weighted_score : Int,
  max_score : Int,
  normalized_score : Int,
) -> QualityMatrix {
  QualityMatrix::{ axes, weighted_score, max_score, normalized_score }
}
