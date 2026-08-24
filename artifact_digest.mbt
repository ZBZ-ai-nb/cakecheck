///|
pub fn scenario_evidence_digest(stdout : String, stderr : String) -> String {
  let normalized_stdout = normalize_evidence(stdout)
  let normalized_stderr = normalize_evidence(stderr)
  let first = rolling_hash(normalized_stdout, 216613626)
  let second = rolling_hash(normalized_stderr, 16777619)
  "evidence-" + first.to_string() + "-" + second.to_string()
}

///|
pub fn scenario_observation_digest(observation : ScenarioObservation) -> String {
  let body = observation.id +
    "\n" +
    observation.target.name() +
    "\n" +
    observation.status.name() +
    "\n" +
    normalize_evidence(observation.stdout) +
    "\n" +
    normalize_evidence(observation.stderr) +
    "\n" +
    observation.duration_ms.to_string()
  scenario_evidence_digest(body, observation.evidence_digest)
}

///|
pub fn normalize_evidence(value : String) -> String {
  let lines = split_lines(value)
  let mut out = ""
  let mut first = true
  let mut index = 0
  while index < lines.length() {
    let line = trim_ascii(lines[index])
    if line.length() > 0 {
      if !first {
        out = out + "\n"
      }
      out = out + line
      first = false
    }
    index += 1
  }
  out
}

///|
pub fn evidence_equal(left : String, right : String) -> Bool {
  normalize_evidence(left) == normalize_evidence(right)
}

///|
pub fn evidence_contains(value : String, fragment : String) -> Bool {
  contains(normalize_evidence(value), normalize_evidence(fragment))
}

///|
fn rolling_hash(value : String, seed : Int) -> Int {
  let mut hash = seed
  let mut index = 0
  while index < value.length() {
    hash = hash * 16777619 + code_at(value, index)
    hash = hash % 2147483629
    if hash < 0 {
      hash = hash + 2147483629
    }
    index += 1
  }
  hash
}

///|
pub fn digest_is_well_formed(value : String) -> Bool {
  starts_with(value, "evidence-") && value.length() > "evidence-0-0".length()
}

///|
pub fn digest_for_lines(lines : Array[String]) -> String {
  let mut joined = ""
  let mut index = 0
  while index < lines.length() {
    if index > 0 {
      joined = joined + "\n"
    }
    joined = joined + normalize_evidence(lines[index])
    index += 1
  }
  scenario_evidence_digest(joined, "")
}

///|
pub fn digest_for_matrix(matrix : ScenarioMatrix) -> String {
  let lines : Array[String] = []
  lines.push(matrix.name)
  lines.push(matrix.version)
  let mut index = 0
  while index < matrix.specs.length() {
    let spec = matrix.specs[index]
    lines.push(spec.id + ":" + spec.target_names() + ":" + spec.command)
    index += 1
  }
  index = 0
  while index < matrix.observations.length() {
    let observation = matrix.observations[index]
    lines.push(
      observation.id +
      ":" +
      observation.target.name() +
      ":" +
      observation.status.name() +
      ":" +
      observation.evidence_digest,
    )
    index += 1
  }
  digest_for_lines(lines)
}
