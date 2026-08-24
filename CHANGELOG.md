# Changelog

## 0.3.0 - local candidate

- Replaced the previous API compatibility/release-gate direction with a cross-target scenario reproduction matrix.
- Added `ScenarioManifest`, `ScenarioMatrix` and explicit `ScenarioObservation` records.
- Added Native, JavaScript, Wasm and Wasm GC target profiles and coverage policies.
- Added deterministic run schedules, evidence digests, replay envelopes and machine-path redaction.
- Added reproduction contracts, scenario history diffs, portability risks and runtime metrics.
- Added observation text/JSON exchange and four built-in scenario fixtures.
- Added 36 tests and runnable matrix/CLI examples.

## 0.2.0 - historical candidate

- This candidate was withdrawn after review because its public API compatibility and SemVer workflow
  overlapped with existing MoonBit projects. Its API-specific implementation is removed from the
  current source tree; the change is recorded here for traceability.

## 0.1.0 - historical package

- Initial package metadata, examples, CI and engineering documentation.
