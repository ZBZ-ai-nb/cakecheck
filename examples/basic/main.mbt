///|
fn main {
  let report = @audit.audit_project(@audit.sample_good_input())
  println("cakecheck example")
  println(report.summary())
  println(report.to_json())
}
