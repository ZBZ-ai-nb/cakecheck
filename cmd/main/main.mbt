///|
fn main {
  let before = "pub fn parse(String) -> String\n"
  let after = before + "pub fn report(String) -> String\n"
  let contract = @audit.build_api_release_contract(
    before, after, "0.1.0", "0.2.0",
  )
  println("CakeCheck API release contract")
  println(contract.summary())
  println(contract.to_markdown())
}
