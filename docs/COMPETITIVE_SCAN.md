# MoonBit 生态重合检索记录

检索日期：2026-08-21
检索范围：公开 GitHub 仓库页面和项目 README。
目的：在重新提交材料前识别与 CakeCheck 主功能相同或相邻的项目，明确输入、输出和非目标。

## 检索结果

| 项目 | 公开定位 | 关系 | CakeCheck 排除的重合点 |
| --- | --- | --- | --- |
| [ZQD-ai-nb/mooncake-auditor](https://github.com/ZQD-ai-nb/mooncake-auditor) | MoonBit 黑客松项目验收检查：README、CI、测试、示例、许可证、Git 历史和发布准备度 | 直接重合（旧定位） | CakeCheck 不再以通用仓库验收清单为主，主功能改为 API 快照与 SemVer 契约 |
| [gywcs101/MoonDocCheck](https://github.com/gywcs101/MoonDocCheck) | 公共 API 文档注释、README、示例和 CI 的文档质量检查 | 相邻 | CakeCheck 不做 `///` 覆盖率、TODO/FIXME 文档检查或 Markdown 文档质量评分 |
| [LL728/moonseal](https://github.com/LL728/moonseal) | 测试充分性、mutation testing、coverage 和发布质量门禁 | 相邻 | CakeCheck 不运行测试分析覆盖率，也不做 mutation testing 或趋势看板 |
| [Tino-hue/moonmark](https://github.com/Tino-hue/moonmark) | MoonBit 依赖图和依赖健康诊断 | 相邻 | CakeCheck 不解析依赖图，不计算依赖健康/新鲜度 |
| [MoonBit `moon info`](https://github.com/moonbitlang/moonbit-docs/blob/main/next/toolchain/moon/commands.md) | 生成 `pkg.generated.mbti` 公共接口快照，并遵循 SemVer 发布约定 | 上游基础能力 | CakeCheck 不替代快照生成；在快照之上增加声明级变化、迁移账本和发布契约 |
| [EJJ-ai-nb/harborcheck](https://github.com/EJJ-ai-nb/harborcheck) | README 示例证明、第三方来源和许可证证明、身份和验收材料 | 相邻 | CakeCheck 不提取 README 证明，不做来源/身份档案 |
| [clbbbb/moonbit-license-audit](https://github.com/clbbbb/moonbit-license-audit) | MoonBit SPDX license metadata auditor | 局部相邻 | CakeCheck 的许可证模块仅作为旧审计兼容接口，主流程不以许可证检查为中心 |

## 重合处理决定

初审反馈指出的风险是合理的：旧标题“包发布前质量审计库”无法和
`mooncake-auditor` 形成足够清晰的边界。本次本地修改采取三项可验证措施：

1. `README.md` 首屏改为公共 API 迁移契约检查器；
2. 新增 `ApiChange`、`ApiMigrationPlan` 和 `ApiReleaseContract`，实现声明级 changed 检测、迁移动作和版本 bump 门禁；
3. 示例、API 文档、设计说明、申报书和任务报告都以快照输入/迁移账本/版本输出为主，并列出明确非目标。

旧的 `AuditReport`、README/CI/license analyzer 等仍保留，是为了兼容已发布包和提供验收
supporting evidence；它们不再是项目的创新主张。这样可以让评审直接从代码和运行示例看到
与通用验收检查器和官方快照生成器都不同的核心工作流。

## 限制

本记录是公开资料的静态检索，不声称穷尽所有未公开或后来创建的项目。重新提交前应以评审
看到的公开仓库状态为准；本仓库不会自动登录、抓取或修改任何外部账号。
