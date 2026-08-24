///|
pub fn build_matrix_timeline(
  matrices : Array[ScenarioMatrix],
) -> MatrixTimeline {
  let snapshots : Array[MatrixSnapshot] = []
  let mut improved = 0
  let mut regressed = 0
  let mut stable = 0
  let mut index = 0
  while index < matrices.length() {
    let matrix = matrices[index]
    snapshots.push(MatrixSnapshot::{
      label: matrix.name + "@" + matrix.version,
      digest: digest_for_matrix(matrix),
      required_count: matrix.required_count,
      passed_count: matrix.passed_count,
      failed_count: matrix.failed_count,
      skipped_count: matrix.skipped_count,
      ready: matrix.passes(),
    })
    if index > 0 {
      let before = snapshots[index - 1]
      let current = snapshots[index]
      let before_score = snapshot_score(before)
      let current_score = snapshot_score(current)
      if current_score > before_score {
        improved += 1
      } else if current_score < before_score {
        regressed += 1
      } else {
        stable += 1
      }
    }
    index += 1
  }
  MatrixTimeline::{ snapshots, improved, regressed, stable }
}

///|
pub fn MatrixTimeline::passes(self : MatrixTimeline) -> Bool {
  self.regressed == 0 && self.snapshots_all_ready()
}

///|
pub fn MatrixTimeline::snapshots_all_ready(self : MatrixTimeline) -> Bool {
  let mut index = 0
  while index < self.snapshots.length() {
    if !self.snapshots[index].ready {
      return false
    }
    index += 1
  }
  true
}

///|
pub fn MatrixTimeline::summary(self : MatrixTimeline) -> String {
  "snapshots=" +
  self.snapshots.length().to_string() +
  ", improved=" +
  self.improved.to_string() +
  ", regressed=" +
  self.regressed.to_string() +
  ", stable=" +
  self.stable.to_string() +
  ", passes=" +
  bool_text(self.passes())
}

///|
pub fn MatrixTimeline::to_markdown(self : MatrixTimeline) -> String {
  let mut out = "# Scenario Matrix Timeline\n\n"
  out = out + "- Passes: " + bool_text(self.passes()) + "\n"
  out = out + "- Improved: " + self.improved.to_string() + "\n"
  out = out + "- Regressed: " + self.regressed.to_string() + "\n"
  out = out + "- Stable: " + self.stable.to_string() + "\n\n"
  out = out +
    "| Snapshot | Required | Passed | Failed | Skipped | Ready | Digest |\n"
  out = out + "| --- | ---: | ---: | ---: | ---: | --- | --- |\n"
  let mut index = 0
  while index < self.snapshots.length() {
    let snapshot = self.snapshots[index]
    out = out + "| `" + snapshot.label + "` | "
    out = out + snapshot.required_count.to_string() + " | "
    out = out + snapshot.passed_count.to_string() + " | "
    out = out + snapshot.failed_count.to_string() + " | "
    out = out + snapshot.skipped_count.to_string() + " | "
    out = out + bool_text(snapshot.ready) + " | `" + snapshot.digest + "` |\n"
    index += 1
  }
  out
}

///|
pub fn MatrixTimeline::to_json(self : MatrixTimeline) -> String {
  let mut out = "{\"passes\":" + bool_text(self.passes()) + ","
  out = out + "\"improved\":" + self.improved.to_string() + ","
  out = out + "\"regressed\":" + self.regressed.to_string() + ","
  out = out + "\"stable\":" + self.stable.to_string() + ",\"snapshots\":["
  let mut index = 0
  while index < self.snapshots.length() {
    if index > 0 {
      out = out + ","
    }
    let snapshot = self.snapshots[index]
    out = out + "{\"label\":\"" + json_escape(snapshot.label) + "\","
    out = out + "\"required\":" + snapshot.required_count.to_string() + ","
    out = out + "\"passed\":" + snapshot.passed_count.to_string() + ","
    out = out + "\"failed\":" + snapshot.failed_count.to_string() + ","
    out = out + "\"skipped\":" + snapshot.skipped_count.to_string() + ","
    out = out + "\"ready\":" + bool_text(snapshot.ready) + ","
    out = out + "\"digest\":\"" + snapshot.digest + "\"}"
    index += 1
  }
  out + "]}"
}

///|
pub fn timeline_ready_count(timeline : MatrixTimeline) -> Int {
  let mut count = 0
  let mut index = 0
  while index < timeline.snapshots.length() {
    if timeline.snapshots[index].ready {
      count += 1
    }
    index += 1
  }
  count
}

///|
pub fn timeline_failed_case_count(timeline : MatrixTimeline) -> Int {
  let mut count = 0
  let mut index = 0
  while index < timeline.snapshots.length() {
    count += timeline.snapshots[index].failed_count
    index += 1
  }
  count
}

///|
fn snapshot_score(snapshot : MatrixSnapshot) -> Int {
  snapshot.passed_count * 3 -
  snapshot.failed_count * 5 -
  snapshot.skipped_count * 2
}
