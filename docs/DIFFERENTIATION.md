# 选题调研与差异化

Date: 2026-08-21

## 结论

早期版本把 CakeCheck 描述为“MoonBit/Mooncakes 包发布前质量审计库”，这个标题和
`ZQD-ai-nb/mooncake-auditor` 的通用项目验收清单存在直接重合，不能继续作为主定位。

本次修改将主定位收窄为：

> CakeCheck：MoonBit 公共 API 迁移契约、迁移账本与 SemVer 漂移检查器。

主输入从仓库验收材料改为两个 `pkg.generated.mbti` 快照和两个版本号；主输出从
readiness 分数改为声明级变化集、稳定迁移任务、最小 bump 和可阻断发版的契约结果。

## 功能边界

| 项目 | 它的重点 | CakeCheck 的明确边界 |
| --- | --- | --- |
| [mooncake-auditor](https://github.com/ZQD-ai-nb/mooncake-auditor) | 通用 README、CI、测试、许可证、提交历史和发布准备度 | 不复制其仓库验收规则；只比较 API 快照并校验版本 bump |
| [MoonDocCheck](https://github.com/gywcs101/MoonDocCheck) | API 文档注释覆盖、README/示例文档质量、HTML/JSON 报告 | 不统计 `///` 覆盖率，不评价文档写作质量 |
| [MoonSeal](https://github.com/LL728/moonseal) | 测试充分性、mutation testing、coverage、质量趋势 | 不运行测试生成覆盖率，不做 mutation testing |
| [moonmark](https://github.com/Tino-hue/moonmark) | 依赖图、循环依赖、依赖新鲜度和健康评分 | 不解析依赖图，不评价第三方依赖健康 |
| [HarborCheck](https://github.com/EJJ-ai-nb/harborcheck) | README 代码块证明、第三方来源/许可证证明、身份和验收证据 | 不提取 README 代码证明，不建立来源或身份材料档案 |
| [moonbit-license-audit](https://github.com/clbbbb/moonbit-license-audit) | SPDX 许可证元数据审计 | 不把许可证识别作为主功能 |

## CakeCheck 的独立贡献

1. 对 `pkg.generated.mbti` 做声明级身份匹配，能把同名 struct/enum 的内容变化归入
   `changed`，避免简单文本 diff 的“删除 + 新增”噪声。
2. 将每个变化生成稳定 ID、风险和 adopt/migrate/replace 动作，形成可交接的 API Migration Ledger。
3. 将 API 变化和 `moon.mod` 版本变化放进同一个纯数据模型，直接判断 release contract
   是否通过。
4. 输出稳定的 Markdown/JSON 契约结果，便于在发布 CI 中阻止错误版本，而不读取网络或账号。
5. 保留旧审计接口作为 supporting evidence，但不再把它们写成选题核心。

## 已知风险和诚实说明

公共 API 版本门禁本身与“release quality”存在领域邻近性，因此 README、申报书和示例都把
输入、输出、非目标写清楚。CakeCheck 不声称覆盖上述项目的测试、文档、依赖或来源证明能力；
它只负责一个具体判断：公共接口快照变化如何转成迁移动作，以及发布的版本号是否准确表达变化。
