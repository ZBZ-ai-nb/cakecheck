///|
pub fn build_replay_envelopes(matrix : ScenarioMatrix) -> Array[ReplayEnvelope] {
  let result : Array[ReplayEnvelope] = []
  let mut spec_index = 0
  while spec_index < matrix.specs.length() {
    let spec = matrix.specs[spec_index]
    let mut target_index = 0
    while target_index < spec.targets.length() {
      let target = spec.targets[target_index]
      match observation_for(matrix.observations, spec.id, target) {
        None => ()
        Some(observation) =>
          result.push(ReplayEnvelope::{
            case_id: spec.id,
            target,
            command: spec.command,
            expected: spec.expected,
            stdout: redact_machine_paths(observation.stdout),
            stderr: redact_machine_paths(observation.stderr),
            duration_ms: observation.duration_ms,
            evidence_digest: observation.evidence_digest,
            replay_key: replay_key(spec, observation),
          })
      }
      target_index += 1
    }
    spec_index += 1
  }
  result
}

///|
pub fn replay_key(
  spec : ScenarioSpec,
  observation : ScenarioObservation,
) -> String {
  let content = spec.id +
    "|" +
    observation.target.name() +
    "|" +
    spec.command +
    "|" +
    spec.expected.name() +
    "|" +
    observation.evidence_digest
  scenario_evidence_digest(content, "")
}

///|
pub fn replay_envelope_to_text(envelope : ReplayEnvelope) -> String {
  "replay case=" +
  envelope.case_id +
  " target=" +
  envelope.target.name() +
  " expected=" +
  envelope.expected.name() +
  " duration_ms=" +
  envelope.duration_ms.to_string() +
  " key=" +
  envelope.replay_key +
  " command=" +
  quote_field(envelope.command) +
  " stdout=" +
  quote_field(envelope.stdout) +
  " stderr=" +
  quote_field(envelope.stderr) +
  " digest=" +
  quote_field(envelope.evidence_digest)
}

///|
pub fn replay_envelopes_to_text(envelopes : Array[ReplayEnvelope]) -> String {
  let mut out = "# CakeCheck replay envelopes\n"
  let mut index = 0
  while index < envelopes.length() {
    out = out + replay_envelope_to_text(envelopes[index]) + "\n"
    index += 1
  }
  out
}

///|
pub fn replay_envelope_to_json(envelope : ReplayEnvelope) -> String {
  let mut out = "{\"case\":\"" + json_escape(envelope.case_id) + "\","
  out = out + "\"target\":\"" + envelope.target.name() + "\","
  out = out + "\"expected\":\"" + envelope.expected.name() + "\","
  out = out + "\"command\":\"" + json_escape(envelope.command) + "\","
  out = out + "\"stdout\":\"" + json_escape(envelope.stdout) + "\","
  out = out + "\"stderr\":\"" + json_escape(envelope.stderr) + "\","
  out = out + "\"duration_ms\":" + envelope.duration_ms.to_string() + ","
  out = out + "\"digest\":\"" + json_escape(envelope.evidence_digest) + "\","
  out + "\"replay_key\":\"" + envelope.replay_key + "\"}"
}

///|
pub fn replay_envelopes_to_json(envelopes : Array[ReplayEnvelope]) -> String {
  let mut out = "["
  let mut index = 0
  while index < envelopes.length() {
    if index > 0 {
      out = out + ","
    }
    out = out + replay_envelope_to_json(envelopes[index])
    index += 1
  }
  out + "]"
}

///|
pub fn replay_envelopes_are_unique(envelopes : Array[ReplayEnvelope]) -> Bool {
  let mut left = 0
  while left < envelopes.length() {
    let mut right = left + 1
    while right < envelopes.length() {
      if envelopes[left].replay_key == envelopes[right].replay_key {
        return false
      }
      right += 1
    }
    left += 1
  }
  true
}

///|
pub fn replay_envelopes_digest(envelopes : Array[ReplayEnvelope]) -> String {
  let lines : Array[String] = []
  let mut index = 0
  while index < envelopes.length() {
    lines.push(envelopes[index].replay_key)
    index += 1
  }
  digest_for_lines(lines)
}

///|
pub fn redact_machine_paths(value : String) -> String {
  let normalized = replace_all(value, "C:\\Users\\", "<user>/")
  replace_all(normalized, "/home/", "<home>/")
}

///|
fn replace_all(text : String, from : String, to : String) -> String {
  if from.length() == 0 {
    return text
  }
  let mut out = ""
  let mut cursor = 0
  while cursor < text.length() {
    match index_of_from(text, from, cursor) {
      None => {
        out = out + slice(text, cursor, text.length())
        cursor = text.length()
      }
      Some(position) => {
        out = out + slice(text, cursor, position) + to
        cursor = position + from.length()
      }
    }
  }
  out
}

///|
fn index_of_from(text : String, needle : String, start : Int) -> Int? {
  if needle.length() > text.length() {
    return None
  }
  let limit = text.length() - needle.length()
  let mut index = start
  while index <= limit {
    if slice(text, index, index + needle.length()) == needle {
      return Some(index)
    }
    index += 1
  }
  None
}
