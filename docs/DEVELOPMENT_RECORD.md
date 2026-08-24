# Development Record

## Timeline

| Date | Work | Status | Evidence |
| --- | --- | --- | --- |
| 2026-08-09 | Created the MoonBit package, README, CI, examples and license | historical | Initial project files |
| 2026-08-17 | Unified GitHub/Mooncakes namespace and added engineering records | historical | `moon.mod`, docs and commit history |
| 2026-08-20 | Added the first release-quality audit draft | historical | Preserved in Git history only |
| 2026-08-21 | Narrowed the draft toward API compatibility after an initial overlap scan | withdrawn | This direction was later rejected in review |
| 2026-08-24 | Investigated the rejection and confirmed direct overlap with `moon_api_guard` and `moonguard` | complete | `docs/COMPETITIVE_SCAN.md` |
| 2026-08-24 | Removed API snapshot/SemVer/migration code and rebuilt the scenario matrix workflow | complete locally | `scenario_*.mbt`, `target_profiles.mbt` |
| 2026-08-24 | Added replay, scheduling, metrics, risk, timeline and contract coverage | complete locally | 36 tests, two runnable examples |
| 2026-08-24 | Updated proposal, README, design, compliance and self-review materials | complete locally | Current working tree |

## Design decisions

| Decision | Reason |
| --- | --- |
| Keep the core pure | A caller can use the same matrix logic in local tools, CI or another MoonBit host |
| Make observations explicit | A declaration alone must not be mistaken for a real run |
| Use target profiles | Native/JS host capabilities differ from Wasm/Wasm GC restrictions |
| Generate stable digests | Reviewers can compare evidence without publishing machine paths |
| Build deterministic schedules | CI artifacts should be comparable across runs |
| Keep API compatibility out of scope | Existing public projects already provide that function; avoiding direct overlap is a hard requirement |

## Local evidence

```text
moon fmt --check: pass
moon check --deny-warn: pass
moon build: pass
moon test --deny-warn: 36 passed, 0 failed
moon run examples/basic: pass
moon run cmd/main: pass
moon info: pass
```

The current local candidate has about 4311 effective MoonBit source lines and 22 source files.
Push and Mooncakes publication are intentionally left for the final account-confirmed step.

## Future work

- Add runner adapters outside the pure core;
- add signed artifact integration without putting credentials in this package;
- add more host capability profiles and target-specific fixtures;
- add optional CI annotation output;
- keep a fresh public overlap scan before any new major feature.
