# CakeCheck

CakeCheck 是一个用 MoonBit 实现的 MoonBit/Mooncakes 包发布前质量审计库。它不是通用文本检查脚本，而是把 MoonBit 开源包验收中最容易遗漏的工程项做成可复用的数据模型、规则集、评分器和报告导出器。

## 解决的问题

MoonBit 包作者在发布前通常需要反复确认 `moon.mod`、README、CI、许可证、提交记录、Mooncakes 发布状态是否一致。CakeCheck 接收这些文件文本和仓库状态，输出结构化检查结果、ready 分数、门禁结果、修复计划、证据矩阵、质量矩阵、发布计划、Markdown 报告和 JSON 摘要，适合接入 CI、发布脚本、课程作业检查器或开源项目维护工具。

## 适用场景

- MoonBit 库作者发布 Mooncakes 包前的自检。
- 黑客松、课程项目、开源活动的验收辅助。
- CI 中生成发布质量报告。
- 维护多个 MoonBit 包时统一检查 README、CI 和许可证规范。
- WebAssembly 工具中对项目文本做轻量审计。

## 安装

发布后可在 MoonBit 项目中添加：

```bash
moon add ZBZ-ai-nb/cakecheck@0.1.0
```

当前 Mooncakes 包名：

```text
ZBZ-ai-nb/cakecheck
```

GitHub 仓库、README、申报书和 `moon.mod` 中的包名保持一致。

## 最小使用示例

```moonbit
let input = @audit.sample_good_input()
let report = @audit.audit_project(input)
println(report.summary())
println(report.to_markdown())
```

完整示例：

```bash
moon run examples/basic
```

CLI smoke 入口：

```bash
moon run cmd/main
```

## API 与核心功能

```moonbit
pub fn audit_project(input : AuditInput) -> AuditReport
pub fn parse_manifest(text : String) -> ManifestInfo
pub fn sample_good_input() -> AuditInput
pub fn sample_risky_input() -> AuditInput
pub fn AuditReport::summary(self : AuditReport) -> String
pub fn AuditReport::to_markdown(self : AuditReport) -> String
pub fn AuditReport::to_json(self : AuditReport) -> String
pub fn AuditReport::has_errors(self : AuditReport) -> Bool
pub fn AuditReport::is_ready(self : AuditReport) -> Bool
pub fn AuditReport::gate(self : AuditReport, profile : AuditProfile) -> GateResult
pub fn AuditReport::remediation_plan(self : AuditReport, limit : Int) -> String
pub fn diff_reports(before : AuditReport, after : AuditReport) -> AuditDiff
pub fn analyze_readme(readme : String) -> ReadmeMetrics
pub fn analyze_workflow(text : String) -> WorkflowInfo
pub fn analyze_license(text : String) -> LicenseFacts
pub fn parse_semver(value : String) -> SemVerInfo
pub fn analyze_namespace(raw : String, repository : String) -> NamespaceInfo
pub fn build_acceptance_evidence(input : AuditInput) -> EvidenceMatrix
pub fn build_release_plan(input : AuditInput) -> ReleasePlan
pub fn build_quality_matrix(input : AuditInput) -> QualityMatrix
pub fn review_acceptance(input : AuditInput) -> AcceptanceReview
```

核心检查包括：

- `moon.mod` 必填字段、包名格式、semver 版本、GitHub 仓库 URL、OSI 许可证字段。
- README 是否包含安装、用法、示例、验收命令、许可证、包名一致性；常见中英文标题都可识别。
- GitHub Actions 是否安装 MoonBit 并运行 `moon check`、`moon build`、`moon test`、`moon run`。
- LICENSE 是否可被轻量识别。
- 仓库是否公开、提交数量是否足够、CHANGELOG 是否存在。
- Mooncakes 发布状态和占位符风险。
- 不同 profile 下的发布门禁结果。
- README 结构指标、CI 命令覆盖、许可证事实、semver 版本比较和包命名空间一致性。
- 验收证据矩阵、Mooncakes 发布计划、质量矩阵和最终验收评审摘要。

## 支持范围

- 以文本形式审计 MoonBit 项目配置和文档。
- 适合 CI、教学验收、发布前检查、Mooncakes 包维护场景。
- 输出结构化 `AuditReport`，可导出 Markdown 和 JSON。
- 支持 Quick、Release、Hackathon 三种门禁 profile。
- 支持生成修复建议计划，优先列出错误和警告。
- 支持比较两次审计结果，展示 ready 分数变化、已修复项和新增问题。
- 支持生成 Acceptance Evidence、Release Plan、Quality Matrix 和 Acceptance Review。
- 不依赖第三方库，不读取外部文件，不访问网络。

## 暂不支持范围

- 不直接替代 `moon check`、`moon build`、`moon test`。
- 不登录 GitHub 或 Mooncakes，也不执行发布。
- 不完整解析 YAML、Markdown AST 或 SPDX 全量许可证库。
- 不自动读取磁盘文件；上层工具负责把文件内容传入 `AuditInput`。

## 本地运行与验收命令

```bash
moon fmt --check
moon check
moon check --deny-warn
moon build
moon test
moon test --deny-warn
moon run examples/basic
moon run cmd/main
moon info
moon publish --dry-run
```

测试覆盖正常项目、风险项目、moon.mod 解析、中英文 README 覆盖项、CI 命令、评分、Markdown 与 JSON 导出、profile 门禁、修复计划、审计 diff、semver、命名空间、证据矩阵、发布计划、质量矩阵和验收评审。

当前 MoonBit 源码规模：

```text
4,776 non-empty non-comment MoonBit code lines
5,462 total .mbt lines
```

## 项目资料

- `HACKATHON_APPLICATION.md`：8 月黑客松一页 Markdown 项目申报书。
- `TASK_REPORT.md`：项目任务报告书。
- `docs/API.md`：公开 API 说明。
- `docs/DESIGN.md`：架构和设计说明。
- `docs/TESTING.md`：测试记录和本地验证命令。
- `docs/ACCEPTANCE_SELF_REVIEW.md`：验收自查证据。
- `docs/PUSH_RELEASE_CHECKLIST.md`：推送和 Mooncakes 发布清单。
- `docs/DEVELOPMENT_RECORD.md`：开发过程、工单和设计决策记录。
- `docs/OPEN_SOURCE_COMPLIANCE.md`：开源许可证、来源和生成文件合规记录。
- `CONTRIBUTING.md`：贡献和本地开发流程。
- `SECURITY.md`：安全边界和问题反馈说明。
- `pkg.generated.mbti`：`moon info` 生成的公开 API 快照。

## Mooncakes 发布

`moon.mod` 发布字段：

```text
name = "ZBZ-ai-nb/cakecheck"
version = "0.1.0"
readme = "README.md"
repository = "https://github.com/ZBZ-ai-nb/cakecheck.git"
license = "MIT"
description = "MoonBit package readiness auditor for Mooncakes releases"
```

发布流程：

```bash
moon login
moon publish --dry-run
moon publish
```

发布后检查：

```text
https://mooncakes.io/docs/ZBZ-ai-nb/cakecheck
https://mooncakes.io/api/v0/manifest/ZBZ-ai-nb/cakecheck
```

## 开源许可证与参考

本项目使用 MIT 许可证。核心实现为原创 MoonBit 代码，不移植第三方源码，不包含来源不明素材。许可证、来源和生成文件说明见 `docs/OPEN_SOURCE_COMPLIANCE.md`。项目规则参考 MoonBit 官方工具链文档和 Mooncakes 包发布要求。
