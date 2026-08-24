# Security Notes

CakeCheck is a pure data-processing library. It accepts scenario text and observation values from
the caller and returns structured reports. The core package does not read files, execute commands,
access the network, log in to GitHub/Mooncakes, store tokens or mutate a repository.

## Evidence handling

Observation stdout and stderr may contain secrets, absolute paths, usernames or service responses.
Callers must inspect output before publishing it. `redact_machine_paths` removes common Windows and
Unix home prefixes, but it is not a secret scanner and must not be treated as one.

Evidence digests identify normalized content; they are not cryptographic signatures. Use a signed
artifact service outside the core library when a release requires authenticity guarantees.

## Scenario commands

The `command` field is descriptive data. CakeCheck never executes it and never interprets shell
metacharacters. A runner or CI adapter that executes commands must apply its own allowlist, timeout,
working-directory and environment isolation.

## Reporting a problem

Do not include tokens, private logs or personal data in a public issue. Provide a minimal scenario
manifest, a redacted observation and the failing test or report code.
