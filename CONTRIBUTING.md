# Contributing to CakeCheck

CakeCheck is a MoonBit cross-target scenario reproduction matrix. Contributions should improve
scenario declarations, observations, target coverage, replay evidence or report quality.

## Development loop

```bash
moon fmt
moon check --deny-warn
moon test --deny-warn
moon run examples/basic
moon run cmd/main
moon info
```

## Design rules

- Keep the core package pure: no file reads, network calls, command execution or credentials.
- Give every new scenario field a parser error, a valid fixture and a report assertion.
- Keep target behavior explicit; do not hide Native/JavaScript/Wasm assumptions in string heuristics.
- Use deterministic ordering and stable digests for records that enter CI artifacts.
- Redact machine-specific paths before sharing observation output.
- Keep the project boundary distinct from API compatibility guards, generic repository auditors and
  benchmark tools. Re-run `docs/COMPETITIVE_SCAN.md` before adding a new major feature.

## Pull requests

Describe the scenario format or data-model change, include tests, update README/API/design docs,
and include a short changelog entry. Do not commit tokens, private command output or personal files.
