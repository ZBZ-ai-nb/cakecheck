# 设计说明

CakeCheck 的定位是 MoonBit 包发布质量门禁，而不是通用 YAML/Markdown/许可证解析器。它通过轻量文本扫描覆盖 Mooncakes 发布前最关键的工程项，降低维护者和评审的复现成本。

## 模块划分

- `model.mbt`：审计输入、检查项、评分和报告数据模型。
- `text.mbt`：ASCII 文本扫描、大小写归一、占位符检查和输出名称转换。
- `manifest.mbt`：`moon.mod` 字段解析、重复字段识别、包名与 semver 校验。
- `checks.mbt`：核心审计规则。
- `report.mbt`：Markdown、JSON 和摘要导出。
- `profile.mbt`：Quick、Release、Hackathon 三类门禁策略。
- `remediation.mbt`：按严重程度生成修复建议。
- `diff.mbt`：比较两次审计报告，识别已修复项和新增问题。
- `scan_utils.mbt`：README、CI 和许可证分析共享的轻量 Markdown/文本扫描工具。
- `readme_analyzer.mbt`：统计 README 结构、命令块、主题覆盖和章节信息。
- `ci_analyzer.mbt`：分析 GitHub Actions 命令、MoonBit 校验覆盖和 target 覆盖。
- `license_analyzer.mbt`：识别常见 OSI 许可证家族和发布所需许可证事实。
- `semver_analyzer.mbt`：解析 semver、比较版本、判断版本 bump 和发布通道。
- `namespace_analyzer.mbt`：校验 Mooncakes 命名空间与 GitHub 仓库的一致性。
- `api_compatibility.mbt`：比较 `pkg.generated.mbti` 公共声明，识别兼容性变化并建议 SemVer bump。
- `evidence_matrix.mbt`：将黑客松验收要求组织为可展示的证据矩阵。
- `release_plan_analyzer.mbt`：生成 Mooncakes 发布计划、命令清单和阻塞项。
- `quality_matrix.mbt`：按文档、CI、许可证、发布、仓库等维度计算加权质量分。
- `acceptance_review.mbt`：汇总审计、证据、质量和发布计划，形成最终验收判断。
- `fixtures.mbt`：可运行示例和测试 fixture。
- `tests.mbt`：覆盖正常、风险、解析、CI、README、导出和评分路径。

## 创新点

- 选题直接服务 MoonBit/Mooncakes 生态，而不是移植通用库。
- 将验收规则表达为可复用 MoonBit 数据结构，便于 CI、教学平台和维护工具集成。
- 将检查结果进一步组织为门禁、修复计划和差异报告，便于真实维护流程使用。
- 将验收要求拆解为 evidence matrix、quality matrix 和 release plan，使审计结果既能给人看，也能被工具继续消费。
- 对 semver、README 结构、CI 命令、许可证事实、Mooncakes 命名空间进行独立建模，避免只靠一组字符串规则给出粗略结论。
- 公共 API 快照比较把“代码能构建”进一步连接到“版本升级是否匹配”，适合发版门禁。
- 在不依赖外部服务的情况下提供可复现检查，评审可直接运行测试和示例。
- 报告导出既适合人读，也适合机器消费。

## 后续维护方向

- 增加真实文件读取适配器。
- 增加 SPDX 许可证识别表。
- 增加 Mooncakes API 结果导入。
- 增加 Git 提交信息规则检查。
- 增加 HTML 报告或 SARIF 导出。
- 增加多仓库批量审计和分数趋势记录。
- 增加 GitHub Actions artifact 模板，自动上传验收证据报告。
- 增加跨版本 API 快照存档和自动生成变更日志。
