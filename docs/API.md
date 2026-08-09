# API 说明

## AuditInput

`AuditInput` 是 CakeCheck 的输入模型，包含 `moon.mod`、README、CI、LICENSE、CHANGELOG 文本，以及仓库公开状态、提交数和 Mooncakes 发布状态。

```moonbit
let input = @audit.sample_good_input()
let report = @audit.audit_project(input)
```

上层工具可以从文件系统、Web 表单或 CI 环境读取文本，然后组装 `AuditInput`。

## AuditReport

`AuditReport` 包含：

- `package_name`：从 `moon.mod` 解析出的包名。
- `version`：从 `moon.mod` 解析出的版本。
- `checks`：每条检查项。
- `score`：通过、提示、警告、错误数量和 ready 分数。

```moonbit
let report = @audit.audit_project(input)
let ok = report.is_ready()
let summary = report.summary()
let markdown = report.to_markdown()
let json = report.to_json()
let gate = report.gate(Hackathon)
let plan = report.remediation_plan(5)
```

## ManifestInfo

`parse_manifest` 解析 MoonBit 包元数据，保留字段、重复字段和格式异常行。

```moonbit
let manifest = @audit.parse_manifest(moon_mod_text)
let name = manifest.package_name()
let version = manifest.version()
```

## 检查分类

- `Manifest`：`moon.mod` 字段和格式。
- `Readme`：README 内容覆盖。
- `CI`：GitHub Actions 命令。
- `License`：许可证文本。
- `Repository`：公开状态、提交记录、CHANGELOG。
- `Release`：Mooncakes 发布与占位符风险。

## 输出格式

Markdown 报告适合放入 CI artifacts、Issue 或发布说明。JSON 摘要适合被其他工具继续处理。

## 门禁 Profile

```moonbit
let quick = report.gate(Quick)
let release = report.gate(Release)
let hackathon = report.gate(Hackathon)
```

- `Quick`：适合日常编辑时快速检查包元数据。
- `Release`：适合发版前检查 README、CI 和许可证。
- `Hackathon`：适合验收前检查，要求没有错误和警告，并覆盖发布证据。

## 修复计划与 Diff

```moonbit
let plan = report.remediation_plan(5)
let diff = @audit.diff_reports(before, after)
let diff_markdown = diff.to_markdown()
```

修复计划会优先列出错误，再列出警告和提示。Diff 用于比较两次审计结果，适合在 CI 中展示一次修改带来的质量变化。
