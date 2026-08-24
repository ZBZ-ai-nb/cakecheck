# CakeCheck: MoonBit Cross-Target Scenario Matrix

[![CI](https://github.com/ZBZ-ai-nb/cakecheck/actions/workflows/ci.yml/badge.svg)](https://github.com/ZBZ-ai-nb/cakecheck/actions/workflows/ci.yml)

CakeCheck is a pure MoonBit toolkit for declaring runnable project scenarios,
recording observations for Native, JavaScript, Wasm and Wasm GC targets, and
turning those observations into a reproducible matrix. It helps a package
maintainer answer a practical question:

> Can another maintainer repeat the same example on the declared targets and
> verify the same output within a bounded time?

The library does not execute commands or access the network. A runner supplies
the observed stdout, stderr, duration and evidence digest. CakeCheck then
validates the record, checks target coverage, generates a deterministic run
plan, and renders Markdown/JSON/replay artifacts for CI or release notes.

## Why this is different

CakeCheck is not a public API compatibility guard. It does not parse `.mbti`
snapshots, compare declarations, classify SemVer changes, or block a release
because an interface changed. Those are different workflows covered by
projects such as [moon_api_guard](https://github.com/FidollarinLA/moon_api_guard)
and [moonguard](https://github.com/QinXi-ai/moonguard).

CakeCheck is also not a generic repository acceptance auditor, documentation
checker, mutation tester, dependency health tool, or benchmark dashboard. Its
input is a scenario manifest plus run observations; its output is a target
matrix, reproducibility contract and replayable evidence record. The public
comparison record is in [`docs/COMPETITIVE_SCAN.md`](docs/COMPETITIVE_SCAN.md).

## Install

The current candidate package is `ZBZ-ai-nb/cakecheck@0.3.0`.

```bash
moon add ZBZ-ai-nb/cakecheck@0.3.0
```

The package name, GitHub repository and `moon.mod` namespace are intentionally
the same. Publishing is performed by the maintainer outside the pure library.

## Scenario manifest

The manifest is a small, reviewable line format. Values containing spaces use
double quotes.

```text
matrix name=demo version=0.3.0
scenario id=hello title=hello-world command="moon run examples/basic" targets=native,js,wasm expected=success output="hello world" timeout_ms=30000 required=true tags=smoke,portable
scenario id=fmt title=format command="moon fmt --check" targets=native expected=success output="format ok" timeout_ms=30000 required=true tags=quality
```

Each scenario has a stable `id`, an exact command, one or more MoonBit targets,
an expected outcome, a bounded timeout, and an optional stable output fragment.
One scenario can therefore describe a portable example while still allowing
host-bound cases to remain explicit.

## Record observations

The runner records one observation for each scenario/target pair. The digest
is deterministic and contains no machine-specific path.

```moonbit
let digest = @audit.scenario_evidence_digest("hello world", "")
let observations = [@audit.ScenarioObservation::{
  id: "hello",
  target: @audit.Native,
  status: @audit.Passed,
  stdout: "hello world",
  stderr: "",
  duration_ms: 14,
  evidence_digest: digest,
}]
```

Use `@audit.parse_observation_records` and
`@audit.observations_to_text` when observations are exchanged as text. The
format includes the target, status, output, duration and digest so a reviewer
can distinguish a real run from a declaration-only placeholder.

## Build reports

```moonbit
let manifest = @audit.parse_scenario_manifest(source)
let matrix = @audit.build_scenario_matrix(
  manifest,
  observations,
  [@audit.Native, @audit.Js, @audit.Wasm],
)
let policy = @audit.default_matrix_policy()
let checked = @audit.apply_policy(matrix, policy)
println(checked.to_markdown())
println(checked.to_json())
```

The matrix validates duplicate IDs, missing observations, unexpected targets,
output mismatches, timeouts, missing evidence, target coverage and expected
failure cases. The toolkit also provides:

- target capability profiles for host-bound and restricted targets;
- deterministic run-plan batches and estimated elapsed time;
- replay envelopes with stable keys and path redaction;
- a reproduction contract made of explicit invariants;
- scenario history diffs for added, removed, regressed and recovered cases;
- portability risk findings and coverage/pass-rate metrics;
- Markdown and JSON output for all major records.

## Runnable examples

```bash
moon run examples/basic
moon run cmd/main
```

The basic example builds a three-target matrix, applies the default policy,
prints target coverage, and emits a deterministic matrix digest. The CLI smoke
example prints a generated run plan and JSON report.

## Validation

```bash
moon fmt --check
moon check --deny-warn
moon build
moon test --deny-warn
moon run examples/basic
moon run cmd/main
moon info
```

GitHub Actions runs the same format, check, build, test and example commands.
The test suite covers parser failures, target coverage, expected failures,
evidence digests, policy rules, schedules, replay envelopes, portability risks,
metrics, history and contract output.

## Scope and safety

CakeCheck is a pure data-processing library. It does not read files, execute
commands, log in to GitHub or Mooncakes, store tokens, or publish packages.
The caller owns command execution and must decide which output is safe to
record. Machine-specific paths can be redacted before evidence is shared.

## Project documents

- [`HACKATHON_APPLICATION.md`](HACKATHON_APPLICATION.md): one-page project proposal.
- [`TASK_REPORT.md`](TASK_REPORT.md): implementation and acceptance report.
- [`docs/API.md`](docs/API.md): public types and scenario format.
- [`docs/DESIGN.md`](docs/DESIGN.md): architecture and boundaries.
- [`docs/COMPETITIVE_SCAN.md`](docs/COMPETITIVE_SCAN.md): public overlap scan.
- [`docs/TESTING.md`](docs/TESTING.md): reproducible test record.
- [`CHANGELOG.md`](CHANGELOG.md): version history.

## License

MIT. The implementation and fixtures in this repository are original MoonBit
code and contain no copied third-party source or media.
