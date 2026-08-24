///|
pub fn target_profile(target : ScenarioTarget) -> TargetProfile {
  match target {
    Native =>
      TargetProfile::{
        target,
        label: "Native executable",
        supports_files: true,
        supports_network: true,
        supports_process: true,
        notes: "Best profile for filesystem and process-backed examples.",
      }
    Js =>
      TargetProfile::{
        target,
        label: "JavaScript runtime",
        supports_files: true,
        supports_network: true,
        supports_process: false,
        notes: "Use Node or a browser host; child-process assumptions are invalid.",
      }
    Wasm =>
      TargetProfile::{
        target,
        label: "WebAssembly",
        supports_files: false,
        supports_network: false,
        supports_process: false,
        notes: "Keep examples deterministic and host-independent.",
      }
    WasmGc =>
      TargetProfile::{
        target,
        label: "WebAssembly GC",
        supports_files: false,
        supports_network: false,
        supports_process: false,
        notes: "Use a host that supports the Wasm GC proposal.",
      }
  }
}

///|
pub fn target_profile_is_restricted(target : ScenarioTarget) -> Bool {
  let profile = target_profile(target)
  !profile.supports_files &&
  !profile.supports_network &&
  !profile.supports_process
}

///|
pub fn target_profile_summary(target : ScenarioTarget) -> String {
  let profile = target_profile(target)
  profile.label +
  ": files=" +
  bool_text(profile.supports_files) +
  ", network=" +
  bool_text(profile.supports_network) +
  ", process=" +
  bool_text(profile.supports_process)
}

///|
pub fn target_profiles_markdown(targets : Array[ScenarioTarget]) -> String {
  let mut out = "| Target | Files | Network | Process | Notes |\n"
  out = out + "| --- | --- | --- | --- | --- |\n"
  let mut index = 0
  while index < targets.length() {
    let profile = target_profile(targets[index])
    out = out + "| `" + profile.target.name() + "` | "
    out = out + bool_text(profile.supports_files) + " | "
    out = out + bool_text(profile.supports_network) + " | "
    out = out + bool_text(profile.supports_process) + " | "
    out = out + profile.notes + " |\n"
    index += 1
  }
  out
}

///|
pub fn target_profiles_json(targets : Array[ScenarioTarget]) -> String {
  let mut out = "["
  let mut index = 0
  while index < targets.length() {
    if index > 0 {
      out = out + ","
    }
    let profile = target_profile(targets[index])
    out = out + "{\"target\":\"" + profile.target.name() + "\","
    out = out + "\"files\":" + bool_text(profile.supports_files) + ","
    out = out + "\"network\":" + bool_text(profile.supports_network) + ","
    out = out + "\"process\":" + bool_text(profile.supports_process) + ","
    out = out + "\"notes\":\"" + json_escape(profile.notes) + "\"}"
    index += 1
  }
  out + "]"
}

///|
pub fn target_profile_supports(
  target : ScenarioTarget,
  capability : String,
) -> Bool {
  let profile = target_profile(target)
  match ascii_lower(trim_ascii(capability)) {
    "files" => profile.supports_files
    "network" => profile.supports_network
    "process" => profile.supports_process
    _ => false
  }
}

///|
pub fn target_profile_capabilities(target : ScenarioTarget) -> Array[String] {
  let profile = target_profile(target)
  let result : Array[String] = []
  if profile.supports_files {
    result.push("files")
  }
  if profile.supports_network {
    result.push("network")
  }
  if profile.supports_process {
    result.push("process")
  }
  result
}
