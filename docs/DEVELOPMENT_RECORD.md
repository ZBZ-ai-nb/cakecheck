# Development Record

This file keeps a lightweight local work record for reviewers. It complements git history when GitHub Issues or pull requests are not used.

## Work Items

| Date | Item | Status | Evidence |
| --- | --- | --- | --- |
| 2026-08-09 | Scaffold MoonBit package metadata | Done | `moon.mod`, initial git commits |
| 2026-08-09 | Implement audit data model and text utilities | Done | `model.mbt`, `text.mbt` |
| 2026-08-09 | Implement moon.mod, README, CI, license and release checks | Done | `manifest.mbt`, `checks.mbt` |
| 2026-08-09 | Add reports, gates, remediation and diff | Done | `report.mbt`, `profile.mbt`, `remediation.mbt`, `diff.mbt` |
| 2026-08-09 | Add runnable example and smoke CLI | Done | `examples/basic`, `cmd/main` |
| 2026-08-09 | Add README, docs, testing notes and CI workflow | Done | `README.md`, `docs`, `.github/workflows/ci.yml` |
| 2026-08-17 | Update participant-facing application material | Done | `HACKATHON_APPLICATION.md`, `TASK_REPORT.md` |
| 2026-08-19 | Expand effective MoonBit code beyond 4k | Done | analyzer modules, test expansion |
| 2026-08-20 | Add acceptance self-review and push/release checklist | Done | `docs/ACCEPTANCE_SELF_REVIEW.md`, `docs/PUSH_RELEASE_CHECKLIST.md` |
| 2026-08-20 | Add contribution, security and open source compliance records | Done | `CONTRIBUTING.md`, `SECURITY.md`, `docs/OPEN_SOURCE_COMPLIANCE.md` |
| 2026-08-20 | Add initial API snapshot compatibility and topic differentiation record | Done | `api_compatibility.mbt`, `docs/DIFFERENTIATION.md` |
| 2026-08-21 | Narrow topic after competitive scan and add migration ledger | Done locally; external push pending | `ApiChange`, `ApiMigrationPlan`, `ApiReleaseContract`, `docs/COMPETITIVE_SCAN.md` |

## Design Decisions

| Decision | Reason |
| --- | --- |
| Keep core implementation in MoonBit | Matches the contest requirement and makes the package reusable in MoonBit projects |
| Accept text inputs instead of reading files directly | Keeps the library usable from CI, web tools, tests and future adapters |
| Use lightweight scanners instead of full YAML/Markdown/SPDX parsers | Avoids third-party dependencies while covering the release-readiness evidence needed for MoonBit packages |
| Add profile gates | Separates quick metadata checks from release and hackathon acceptance checks |
| Add evidence and quality matrices | Makes acceptance status explainable and easier to review |
| Keep publishing manual | Avoids mixing local audit logic with account credentials and external side effects |
| Compare generated API snapshots | Connects public API changes to SemVer release intent without reading files or using network access |
| Keep general audit code as a compatibility layer | Preserves the already published package surface while making the API release contract the primary project boundary |
| Generate a migration ledger | Turns snapshot changes into stable, reviewable actions without pretending to inspect downstream callers |

## Validation Record

Latest previously recorded validation before the 2026-08-21 local change:

```text
moon fmt --check: pass
moon check: pass
moon check --deny-warn: pass
moon build: pass
moon test: 22 passed, 0 failed
moon test --deny-warn: 22 passed, 0 failed
moon run examples/basic: pass
moon run cmd/main: pass
moon info: pass
git diff --exit-code -- API snapshots: pass
git diff --check: pass
```

## Current Follow-Up Items

Local validation and generated snapshot review are complete.

- Commit and push only after the correct GitHub identity is confirmed.
- Publish a new Mooncakes version only after the final version number is selected.
- Commit and push only after the correct GitHub identity is confirmed.
- Publish a new Mooncakes version only after the final version number is selected.

Longer-term maintenance:

- Add a file-system adapter that reads real repository files into `AuditInput`.
- Add a broader SPDX license identifier table.
- Add a Mooncakes API result importer.
- Add a GitHub Actions artifact report template.
- Add batch auditing for multiple MoonBit packages.
