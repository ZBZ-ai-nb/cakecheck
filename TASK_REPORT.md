# CakeCheck 项目任务报告书

## 基本信息

- 项目名称：CakeCheck
- 项目定位：MoonBit/Mooncakes 包发布前质量审计库
- 参赛者：张丙政
- 联系方式：17355718297 / 3525658676@qq.com
- GitHub 仓库链接：https://github.com/ZBZ-ai-nb/cakecheck
- Mooncakes 包名：ZBZ-ai-nb/cakecheck
- 开源许可证：MIT

## 项目背景与选题说明

CakeCheck 面向 MoonBit 开源包发布和验收场景，解决包作者在发布前反复检查 `moon.mod`、README、CI、许可证、提交记录、CHANGELOG 和 Mooncakes 发布状态的问题。项目不是通用文本检查脚本，也不是简单示例工程，而是将 MoonBit/Mooncakes 生态中的包发布质量要求沉淀为可复用的数据模型、审计规则、评分系统、门禁 profile、证据矩阵、质量矩阵、发布计划和报告导出能力。

该选题直接服务 MoonBit 生态建设，聚焦 Mooncakes 包发布质量这一细分需求，避免与常见算法库、示例工程或通用脚手架雷同。它适合作为 Mooncakes 包作者、课程项目、黑客松验收和 CI 发布流程中的质量门禁工具，具有明确功能边界和后续维护价值。

## 主要功能

- 解析并校验 `moon.mod` 的必填字段、包名格式、semver 版本、GitHub 仓库 URL 和许可证字段；
- 检查 README 是否包含安装、使用、示例、验收命令、许可证和包名一致性，支持常见中英文标题识别；
- 检查 GitHub Actions 是否安装 MoonBit，并覆盖 `moon check`、`moon build`、`moon test`、`moon run`；
- 检查 LICENSE、CHANGELOG、仓库公开状态、提交数量和 Mooncakes 发布状态；
- 输出 `AuditReport`、ready 分数、Markdown 报告和 JSON 摘要；
- 提供 Quick、Release、Hackathon 三种门禁 profile；
- 提供修复建议计划和两次审计结果 diff；
- 提供 README 结构分析、CI workflow 覆盖分析、许可证事实识别、semver 解析比较和 Mooncakes 命名空间一致性检查；
- 提供 Acceptance Evidence 证据矩阵、Release Plan 发布计划、Quality Matrix 加权质量评分和 Acceptance Review 最终验收判断；
- 比较 `pkg.generated.mbti` 公共 API 快照，识别新增/删除声明并给出 SemVer major/minor 版本建议；
- 提供可运行示例、CLI smoke 入口和完整单元测试。

## 工程实现

项目以 MoonBit 为主要实现语言，核心模块包括：

- `model.mbt`：审计输入、检查项、评分、报告、门禁和 diff 数据模型；
- `text.mbt`：轻量文本扫描、大小写归一、占位符检查等基础能力；
- `manifest.mbt`：`moon.mod` 字段解析、重复字段识别、包名和版本校验；
- `checks.mbt`：README、CI、许可证、仓库和发布状态审计规则；
- `report.mbt`：Markdown 和 JSON 报告导出；
- `profile.mbt`：Quick、Release、Hackathon 门禁策略；
- `remediation.mbt`：按严重程度生成修复建议；
- `diff.mbt`：比较两次审计报告并输出改进情况；
- `scan_utils.mbt`：共享文本、Markdown、命令、链接、标题和 token 扫描工具；
- `readme_analyzer.mbt`：README 章节、命令块、主题覆盖和结构指标分析；
- `ci_analyzer.mbt`：GitHub Actions 命令、MoonBit 安装、check/build/test/run 和 target 覆盖分析；
- `license_analyzer.mbt`：常见 OSI 许可证家族、授权、免责声明和发布可用性分析；
- `semver_analyzer.mbt`：semver prerelease/build metadata 解析、版本比较和 bump 建议；
- `namespace_analyzer.mbt`：Mooncakes owner/package 命名空间与 GitHub 仓库一致性检查；
- `api_compatibility.mbt`：比较公共 API 快照并判断兼容性和版本升级意图；
- `evidence_matrix.mbt`：将验收要求转化为可展示、可导出的证据矩阵；
- `release_plan_analyzer.mbt`：生成 Mooncakes 发布命令、验证步骤和阻塞项；
- `quality_matrix.mbt`：从 metadata、README、CI、license、repository、release、maintainability 维度计算质量分；
- `acceptance_review.mbt`：汇总审计报告、证据矩阵、质量矩阵和发布计划，输出最终验收判断；
- `fixtures.mbt` / `tests.mbt`：测试 fixture 和核心功能测试。

当前 MoonBit 源码规模为 4,929 行非空、非注释 MoonBit 代码，`.mbt` 物理总行数为 5,638 行，达到 8 月黑客松 4,000 行以上参考规模。新增代码均对应实际功能、测试和文档，不通过空文件或无意义拆分凑行数。

## 测试与验证

本地已通过以下命令：

```bash
moon check
moon check --deny-warn
moon fmt --check
moon build
moon test
moon test --deny-warn
moon run examples/basic
moon run cmd/main
```

测试结果：

```text
Total tests: 20, passed: 20, failed: 0.
```

测试覆盖正常项目、风险项目、`moon.mod` 解析、README 覆盖项、中英文小节识别、CI 命令覆盖、评分统计、Markdown/JSON 导出、门禁 profile、修复计划、审计 diff、semver、命名空间、README/CI/license 增强分析、证据矩阵、发布计划、质量矩阵和验收评审。

## 持续集成与发布准备

项目已配置 GitHub Actions CI，覆盖 MoonBit 安装、检查、构建、测试、示例运行和 CLI smoke test。`moon.mod` 已包含 Mooncakes 发布所需字段：

```text
name = "ZBZ-ai-nb/cakecheck"
version = "0.1.0"
readme = "README.md"
repository = "https://github.com/ZBZ-ai-nb/cakecheck.git"
license = "MIT"
description = "MoonBit package readiness auditor for Mooncakes releases"
```

正式提交前需要确认 Mooncakes owner 与包名可用，然后执行：

```bash
moon login
moon publish --dry-run
moon publish
```

## 开源合规说明

项目采用 MIT 许可证。核心代码为原创 MoonBit 实现，不移植第三方源码，不包含来源不明素材、图片、音频、字体或私有代码。项目规则参考 MoonBit 官方工具链文档和 Mooncakes 包发布要求。

## 当前完成情况

项目已完成 MoonBit 包配置、4,000 行以上有效源码、测试、示例、README、许可证、GitHub Actions CI、API 文档、设计说明、测试记录、CHANGELOG、申报书和本任务报告书。当前本地 Git 仓库包含可追踪提交记录，项目已具备推送公开仓库和发布 Mooncakes 包的基础条件。

## 后续计划

- 确认正确的 GitHub Desktop 账号后推送公开仓库，并核对默认分支和 Actions 结果；
- 确认 Mooncakes owner 账号后执行 `moon publish --dry-run` 并完成正式发布；
- 增加真实文件读取适配器；
- 增加 SPDX 许可证识别表；
- 增加 Mooncakes API 结果导入；
- 增加 Git 提交信息规则检查；
- 增加 HTML 报告或 SARIF 导出。
