///|
pub fn scenario_metrics(matrix : ScenarioMatrix) -> ScenarioMetrics {
  let stats = scenario_stats(matrix)
  let mut covered_target_count = 0
  let required_target_count = matrix.coverage.length()
  let mut target_index = 0
  while target_index < matrix.coverage.length() {
    if matrix.coverage[target_index].complete {
      covered_target_count += 1
    }
    target_index += 1
  }
  let mut total_duration_ms = 0
  let mut min_duration_ms = 0
  let mut max_duration_ms = 0
  let mut observation_index = 0
  while observation_index < matrix.observations.length() {
    let duration = matrix.observations[observation_index].duration_ms
    total_duration_ms += duration
    if observation_index == 0 || duration < min_duration_ms {
      min_duration_ms = duration
    }
    if duration > max_duration_ms {
      max_duration_ms = duration
    }
    observation_index += 1
  }
  let coverage_percent = if stats.target_case_count == 0 {
    0
  } else {
    stats.observed_case_count * 100 / stats.target_case_count
  }
  let pass_percent = if stats.observed_case_count == 0 {
    0
  } else {
    stats.passed_case_count * 100 / stats.observed_case_count
  }
  let balance_score = metric_balance_score(matrix.coverage)
  ScenarioMetrics::{
    scenario_count: stats.scenario_count,
    target_case_count: stats.target_case_count,
    observed_case_count: stats.observed_case_count,
    covered_target_count,
    required_target_count,
    passed_count: stats.passed_case_count,
    failed_count: stats.failed_case_count,
    skipped_count: stats.missing_case_count,
    total_duration_ms,
    min_duration_ms,
    max_duration_ms,
    coverage_percent,
    pass_percent,
    balance_score,
  }
}

///|
pub fn ScenarioMetrics::ready(self : ScenarioMetrics) -> Bool {
  self.coverage_percent == 100 &&
  self.pass_percent == 100 &&
  self.balance_score >= 80
}

///|
pub fn ScenarioMetrics::summary(self : ScenarioMetrics) -> String {
  "cases=" +
  self.target_case_count.to_string() +
  ", observed=" +
  self.observed_case_count.to_string() +
  ", coverage=" +
  self.coverage_percent.to_string() +
  "%" +
  ", pass=" +
  self.pass_percent.to_string() +
  "%" +
  ", duration=" +
  self.total_duration_ms.to_string() +
  "ms" +
  ", balance=" +
  self.balance_score.to_string() +
  ", ready=" +
  bool_text(self.ready())
}

///|
pub fn ScenarioMetrics::to_markdown(self : ScenarioMetrics) -> String {
  let mut out = "# Scenario Metrics\n\n"
  out = out + "- Ready: " + bool_text(self.ready()) + "\n"
  out = out + "- Scenarios: " + self.scenario_count.to_string() + "\n"
  out = out + "- Target cases: " + self.target_case_count.to_string() + "\n"
  out = out + "- Observed cases: " + self.observed_case_count.to_string() + "\n"
  out = out + "- Target coverage: " + self.coverage_percent.to_string() + "% ("
  out = out + self.covered_target_count.to_string() + "/"
  out = out + self.required_target_count.to_string() + ")\n"
  out = out + "- Passing observations: " + self.passed_count.to_string() + "\n"
  out = out + "- Failed observations: " + self.failed_count.to_string() + "\n"
  out = out + "- Skipped observations: " + self.skipped_count.to_string() + "\n"
  out = out + "- Pass rate: " + self.pass_percent.to_string() + "%\n"
  out = out + "- Duration: " + self.total_duration_ms.to_string() + " ms\n"
  out = out + "- Min duration: " + self.min_duration_ms.to_string() + " ms\n"
  out = out + "- Max duration: " + self.max_duration_ms.to_string() + " ms\n"
  out + "- Target balance: " + self.balance_score.to_string() + "/100\n"
}

///|
pub fn ScenarioMetrics::to_json(self : ScenarioMetrics) -> String {
  "{\"ready\":" +
  bool_text(self.ready()) +
  ",\"scenarios\":" +
  self.scenario_count.to_string() +
  ",\"cases\":" +
  self.target_case_count.to_string() +
  ",\"observed\":" +
  self.observed_case_count.to_string() +
  ",\"covered_targets\":" +
  self.covered_target_count.to_string() +
  ",\"required_targets\":" +
  self.required_target_count.to_string() +
  ",\"passed\":" +
  self.passed_count.to_string() +
  ",\"failed\":" +
  self.failed_count.to_string() +
  ",\"skipped\":" +
  self.skipped_count.to_string() +
  ",\"total_duration_ms\":" +
  self.total_duration_ms.to_string() +
  ",\"min_duration_ms\":" +
  self.min_duration_ms.to_string() +
  ",\"max_duration_ms\":" +
  self.max_duration_ms.to_string() +
  ",\"coverage_percent\":" +
  self.coverage_percent.to_string() +
  ",\"pass_percent\":" +
  self.pass_percent.to_string() +
  ",\"balance_score\":" +
  self.balance_score.to_string() +
  "}"
}

///|
pub fn metrics_target_gap(metrics : ScenarioMetrics) -> Int {
  metrics.required_target_count - metrics.covered_target_count
}

///|
pub fn metrics_average_duration(metrics : ScenarioMetrics) -> Int {
  if metrics.observed_case_count == 0 {
    0
  } else {
    metrics.total_duration_ms / metrics.observed_case_count
  }
}

///|
fn metric_balance_score(coverage : Array[TargetCoverage]) -> Int {
  if coverage.length() == 0 {
    return 0
  }
  let mut minimum = 100
  let mut maximum = 0
  let mut index = 0
  while index < coverage.length() {
    let item = coverage[index]
    let percentage = if item.required_cases == 0 {
      0
    } else {
      item.passed_cases * 100 / item.required_cases
    }
    if percentage < minimum {
      minimum = percentage
    }
    if percentage > maximum {
      maximum = percentage
    }
    index += 1
  }
  let spread = maximum - minimum
  if spread >= 100 {
    0
  } else {
    100 - spread
  }
}
