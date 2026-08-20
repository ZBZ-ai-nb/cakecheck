# Contributing

CakeCheck is a MoonBit package readiness audit library. Contributions should keep the project focused on MoonBit/Mooncakes release quality, not general-purpose linting.

## Local Setup

Install the MoonBit toolchain, then run:

```bash
moon version --all
moon fmt --check
moon check --deny-warn
moon build
moon test --deny-warn
moon run examples/basic
moon run cmd/main
moon info
```

If `moon info` changes generated interface files, review the public API diff before committing.

## Development Rules

- Keep core logic in MoonBit.
- Add tests for new audit rules, analyzers, reports or data models.
- Keep README and docs aligned with public APIs.
- Do not add network calls to the core library; account-side actions such as GitHub push and Mooncakes publish remain manual.
- Do not commit generated build artifacts from `_build`, `.moon`, `target` or executable outputs.
- Keep third-party code, fixtures and copied text out of the repository unless their license is documented.

## Commit Guidance

Use meaningful commits that explain the change:

```text
feat: add workflow analyzer coverage
test: cover release plan blockers
docs: update acceptance evidence
```

Avoid empty commits, duplicated commits and mechanical line-count changes.

## Pull Request Checklist

- `moon fmt --check` passes.
- `moon check --deny-warn` passes.
- `moon build` passes.
- `moon test --deny-warn` passes.
- At least one runnable example still works.
- Public API snapshot is reviewed after `moon info`.
- README, changelog and relevant docs are updated.
