///|
fn main {
  let report = @audit.audit_project(@audit.sample_good_input())
  println("cakecheck example")
  println(report.summary())
  println(report.to_json())
  let api_change = @audit.analyze_api_compatibility(
    "pub fn parse(String) -> String\n", "pub fn parse(String) -> String\npub fn report(String) -> String\n",
  )
  println(api_change.summary())
}
