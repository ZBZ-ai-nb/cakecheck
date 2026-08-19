///|
pub fn sample_good_input() -> AuditInput {
  audit_input(
    "name = \"ZBZ-ai-nb/cakecheck\"\nversion = \"0.1.0\"\nreadme = \"README.md\"\nrepository = \"https://github.com/ZBZ-ai-nb/cakecheck.git\"\nlicense = \"MIT\"\ndescription = \"MoonBit package readiness auditor\"\npreferred_target = \"wasm\"\n",
    "# CakeCheck\n\n## Installation\nmoon add ZBZ-ai-nb/cakecheck@0.1.0\n\n## Usage\nRun the audit against project text.\n\n## Example\nmoon run examples/basic\n\n## Validation\nmoon check\nmoon build\nmoon test\nmoon publish --dry-run\n\n## License\nMIT\n\nPackage: ZBZ-ai-nb/cakecheck\n",
    "name: CI\nsteps:\n  - run: curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash\n  - run: moon check\n  - run: moon build\n  - run: moon test\n  - run: moon run examples/basic\n",
    "MIT License\n\nPermission is hereby granted, free of charge, to any person obtaining a copy\n",
    "# Changelog\n\n## 0.1.0\n\n- Initial release.\n", true, 8, true,
  )
}

///|
pub fn sample_risky_input() -> AuditInput {
  audit_input(
    "name = \"your-owner/demo\"\nversion = \"0.1\"\nreadme = \"\"\nrepository = \"https://github.com/example/demo\"\nlicense = \"Commercial\"\n",
    "# Demo\n\nTODO\n", "name: CI\nsteps:\n  - run: moon check\n", "", "", false,
    1, false,
  )
}
