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

Expected local state:

```text
main...origin/main [ahead 1]
```

The exact `ahead` number may increase as local checklist/documentation commits are added. Before pushing, confirm these important commits are included in local `main`:

```text
b598656 docs: add acceptance self review checklist
bcf588e feat: expand acceptance audit analyzers
057202e fix: refresh API snapshots for current MoonBit
```

## GitHub Desktop Push Steps

1. Open GitHub Desktop.
2. Confirm the signed-in account is the intended owner or has write access to `ZBZ-ai-nb/cakecheck`.
3. Select repository `cakecheck`.
4. Confirm current branch is `main`.
5. Confirm it says the branch is ahead of origin.
6. Click `Push origin`.
7. Open the repository page and confirm the latest local `main` commit is visible and commit `bcf588e` is included.
8. Check the `Actions` tab and wait for CI to finish.

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

## Mooncakes Release Steps (Already Completed)

Run these only after confirming the correct Mooncakes account/owner:

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
