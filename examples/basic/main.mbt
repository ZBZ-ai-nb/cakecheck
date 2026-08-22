///|
fn main {
  let before = "pub fn parse(String) -> String\npub(all) struct Config {\nvalue : String\n}\n"
  let after = "pub fn parse(String) -> String\npub fn report(String) -> String\npub(all) struct Config {\nvalue : Int\n}\n"
  let contract = @audit.build_api_release_contract(
    before, after, "0.1.0", "1.0.0",
  )
  println("cakecheck API release contract example")
  println(contract.summary())
  println(contract.to_markdown())
  println(contract.to_json())
}
