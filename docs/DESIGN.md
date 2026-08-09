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
- `fixtures.mbt`：可运行示例和测试 fixture。
- `tests.mbt`：覆盖正常、风险、解析、CI、README、导出和评分路径。

## 创新点

- 选题直接服务 MoonBit/Mooncakes 生态，而不是移植通用库。
- 将验收规则表达为可复用 MoonBit 数据结构，便于 CI、教学平台和维护工具集成。
- 将检查结果进一步组织为门禁、修复计划和差异报告，便于真实维护流程使用。
- 在不依赖外部服务的情况下提供可复现检查，评审可直接运行测试和示例。
- 报告导出既适合人读，也适合机器消费。

## 后续维护方向

- 增加真实文件读取适配器。
- 增加 SPDX 许可证识别表。
- 增加 Mooncakes API 结果导入。
- 增加 Git 提交信息规则检查。
- 增加 HTML 报告或 SARIF 导出。
