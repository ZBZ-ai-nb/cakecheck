# Push And Release Checklist

Use this checklist when the correct GitHub Desktop account is ready. Nothing in this file requires changing accounts.

## Do Not Mix Accounts

- Do not push while GitHub Desktop is logged in to an unrelated account.
- Do not run `git push` from a terminal if you are unsure which credential helper account will be used.
- Do not edit global Git credential settings just to finish this project.
- Keep the repository remote as `https://github.com/ZBZ-ai-nb/cakecheck.git`.

## Before Push

Local repository path:

```text
C:\Users\11619\Documents\Codex\2026-08-09\moonbit-readme-ci-mooncakes-io-git-8\outputs\mooncake_audit
```

Expected remote:

```text
origin https://github.com/ZBZ-ai-nb/cakecheck.git
```

Current final state:

```text
main...origin/main
HEAD 2576c2b
```

The final push is complete. The latest default-branch CI run is successful and the following important commits are included:

```text
b598656 docs: add acceptance self review checklist
bcf588e feat: expand acceptance audit analyzers
057202e fix: refresh API snapshots for current MoonBit
2576c2b docs: record published package status
```

## GitHub Desktop Push Record

The `cakecheck/main` push was completed through GitHub Desktop under the `ZBZ-ai-nb` account. The repository is synchronized at `2576c2b`; no further push is required.

## Submission Link

Use this GitHub repository link for the August Hackathon form:

```text
https://github.com/ZBZ-ai-nb/cakecheck
```

Use this application report file as the one-page Markdown project proposal:

```text
HACKATHON_APPLICATION.md
```

## Mooncakes Release Status

The package was published successfully on 2026-08-20 using the confirmed `ZBZ-ai-nb` account. The public manifest reports `ZBZ-ai-nb/cakecheck@0.1.0` with `has_package=true`.

Public package page:

```text
https://mooncakes.io/docs/ZBZ-ai-nb/cakecheck
```

## Mooncakes Release Record (Completed)

The following commands were completed under the confirmed Mooncakes owner account:

```bash
moon login
moon publish --dry-run
moon publish
```

Expected package name:

```text
ZBZ-ai-nb/cakecheck
```

Expected version:

```text
0.1.0
```

After publishing, record the package page in the submission notes:

```text
https://mooncakes.io/docs/ZBZ-ai-nb/cakecheck
```

Public manifest check on 2026-08-20 returned the published package record:

```text
https://mooncakes.io/api/v0/manifest/ZBZ-ai-nb/cakecheck
```

## Final Acceptance Checks

- GitHub repository is public.
- Latest local commits are visible on GitHub default branch `main`.
- GitHub Actions CI passes on the latest commit.
- `README.md` renders correctly on GitHub.
- `LICENSE` is visible at repository root.
- `HACKATHON_APPLICATION.md` is visible and concise enough for submission.
- `docs/ACCEPTANCE_SELF_REVIEW.md` records local validation evidence.
- `docs/OPEN_SOURCE_COMPLIANCE.md` records license and provenance evidence.
- Mooncakes package is published and accessible; verified through the public manifest and package page.
