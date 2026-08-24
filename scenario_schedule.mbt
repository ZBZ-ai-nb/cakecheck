///|
pub fn build_schedule(matrix : ScenarioMatrix) -> Array[ScheduleBatch] {
  let batches : Array[ScheduleBatch] = []
  let targets = all_scenario_targets()
  let mut target_index = 0
  let mut batch_index = 0
  while target_index < targets.length() {
    let target = targets[target_index]
    let steps : Array[ScheduleStep] = []
    let mut step_index = 0
    let mut spec_index = 0
    while spec_index < matrix.specs.length() {
      let spec = matrix.specs[spec_index]
      if spec.has_target(target) {
        steps.push(ScheduleStep::{
          index: step_index,
          case_id: scenario_case_key(spec.id, target),
          target,
          lane: schedule_lane(target),
          command: spec.command,
          estimated_ms: schedule_estimate(matrix, spec),
        })
        step_index += 1
      }
      spec_index += 1
    }
    if steps.length() > 0 {
      batches.push(ScheduleBatch::{
        index: batch_index,
        target,
        lane: schedule_lane(target),
        steps,
        parallel_safe: schedule_lane(target) == Restricted,
      })
      batch_index += 1
    }
    target_index += 1
  }
  batches
}

///|
pub fn schedule_lane(target : ScenarioTarget) -> ScheduleLane {
  match target {
    Native => HostBound
    Js => HostBound
    Wasm => Restricted
    WasmGc => Restricted
  }
}

///|
pub fn schedule_total_estimate(batches : Array[ScheduleBatch]) -> Int {
  let mut total = 0
  let mut batch_index = 0
  while batch_index < batches.length() {
    let batch = batches[batch_index]
    let mut batch_total = 0
    let mut step_index = 0
    while step_index < batch.steps.length() {
      batch_total += batch.steps[step_index].estimated_ms
      step_index += 1
    }
    if batch.parallel_safe && batch.steps.length() > 0 {
      let mut largest = 0
      step_index = 0
      while step_index < batch.steps.length() {
        if batch.steps[step_index].estimated_ms > largest {
          largest = batch.steps[step_index].estimated_ms
        }
        step_index += 1
      }
      total += largest
    } else {
      total += batch_total
    }
    batch_index += 1
  }
  total
}

///|
pub fn schedule_is_deterministic(batches : Array[ScheduleBatch]) -> Bool {
  let mut expected_batch = 0
  let mut batch_index = 0
  while batch_index < batches.length() {
    let batch = batches[batch_index]
    if batch.index != expected_batch || batch.steps.length() == 0 {
      return false
    }
    let mut expected_step = 0
    let mut step_index = 0
    while step_index < batch.steps.length() {
      if batch.steps[step_index].index != expected_step ||
        batch.steps[step_index].target != batch.target {
        return false
      }
      expected_step += 1
      step_index += 1
    }
    expected_batch += 1
    batch_index += 1
  }
  true
}

///|
pub fn schedule_markdown(batches : Array[ScheduleBatch]) -> String {
  let mut out = "# Scenario Execution Schedule\n\n"
  out = out + "- Batches: " + batches.length().to_string() + "\n"
  out = out +
    "- Estimated elapsed time: " +
    schedule_total_estimate(batches).to_string()
  out = out + " ms\n\n"
  let mut batch_index = 0
  while batch_index < batches.length() {
    let batch = batches[batch_index]
    out = out + "## Batch " + batch.index.to_string() + " - `"
    out = out + batch.target.name() + "`\n\n"
    out = out + "- Lane: " + batch.lane.name() + "\n"
    out = out + "- Parallel safe: " + bool_text(batch.parallel_safe) + "\n\n"
    out = out +
      "| Step | Case | Estimate | Command |\n| ---: | --- | ---: | --- |\n"
    let mut step_index = 0
    while step_index < batch.steps.length() {
      let step = batch.steps[step_index]
      out = out + "| " + step.index.to_string() + " | `" + step.case_id + "` | "
      out = out +
        step.estimated_ms.to_string() +
        " ms | `" +
        step.command +
        "` |\n"
      step_index += 1
    }
    out = out + "\n"
    batch_index += 1
  }
  out
}

///|
pub fn schedule_json(batches : Array[ScheduleBatch]) -> String {
  let mut out = "{\"deterministic\":" +
    bool_text(schedule_is_deterministic(batches)) +
    ",\"estimate_ms\":" +
    schedule_total_estimate(batches).to_string() +
    ",\"batches\":["
  let mut batch_index = 0
  while batch_index < batches.length() {
    if batch_index > 0 {
      out = out + ","
    }
    let batch = batches[batch_index]
    out = out + "{\"index\":" + batch.index.to_string() + ","
    out = out + "\"target\":\"" + batch.target.name() + "\","
    out = out + "\"lane\":\"" + batch.lane.name() + "\","
    out = out +
      "\"parallel_safe\":" +
      bool_text(batch.parallel_safe) +
      ",\"steps\":["
    let mut step_index = 0
    while step_index < batch.steps.length() {
      if step_index > 0 {
        out = out + ","
      }
      let step = batch.steps[step_index]
      out = out + "{\"index\":" + step.index.to_string() + ","
      out = out + "\"case\":\"" + json_escape(step.case_id) + "\","
      out = out + "\"estimate_ms\":" + step.estimated_ms.to_string() + ","
      out = out + "\"command\":\"" + json_escape(step.command) + "\"}"
      step_index += 1
    }
    out = out + "]}"
    batch_index += 1
  }
  out + "]}"
}

///|
fn schedule_estimate(matrix : ScenarioMatrix, spec : ScenarioSpec) -> Int {
  match observation_for(matrix.observations, spec.id, spec.targets[0]) {
    None => if spec.timeout_ms > 60000 { 60000 } else { spec.timeout_ms }
    Some(observation) => observation.duration_ms
  }
}
