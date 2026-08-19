///|
fn main {
  let good = @audit.audit_project(@audit.sample_good_input())
  let risky = @audit.audit_project(@audit.sample_risky_input())
  println("CakeCheck smoke report")
  println(good.summary())
  println(risky.summary())
  println(risky.to_markdown())
}
