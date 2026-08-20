# Security Policy

CakeCheck is a local audit library. It accepts text supplied by a caller and returns structured reports. The core package is designed to avoid account credentials, network access, file deletion and repository mutation.

## Supported Version

| Version | Supported |
| --- | --- |
| 0.1.x | Yes |

## Reporting Issues

For contest review and repository maintenance, open a GitHub issue in the public repository after confirming the correct account is being used:

```text
https://github.com/ZBZ-ai-nb/cakecheck
```

Do not include access tokens, Mooncakes credentials, private repository URLs or personal identity documents in public issues.

## Security Boundaries

CakeCheck does not:

- log in to GitHub or Mooncakes;
- push commits;
- publish packages;
- delete files;
- execute commands supplied by audited README or CI text;
- fetch remote resources from the core library.

Future adapters that read files, call APIs or publish packages should be implemented outside the core audit library and should document their credential handling separately.
