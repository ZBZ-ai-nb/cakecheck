# MoonBit 公开项目重合检索记录

检索日期：2026-08-24

检索方式：通过公开 GitHub 仓库搜索、项目 README 和 MoonBit 官方 OSC2026 仓库页面核对
项目定位。目的不是声称穷尽所有作品，而是针对当前选题的关键词和初审反馈做保守排除。

## 直接重合风险

| 项目 | 公开定位 | 与 CakeCheck 的关系 | 当前版本的排除措施 |
| --- | --- | --- | --- |
| [FidollarinLA/moon_api_guard](https://github.com/FidollarinLA/moon_api_guard) | 比较新旧 `.mbti` 接口快照，输出 breaking/compatible、SemVer 建议、CI 退出码和多种报告 | 初审点名的直接重合对象 | CakeCheck 不读取或解析 `.mbti`，不比较声明，不输出 SemVer 建议，不做 API 门禁 |
| [QinXi-ai/moonguard](https://github.com/QinXi-ai/moonguard) | MoonBit public API compatibility and SemVer guard，支持目录比较、策略、release plan 和 CI | 同一 API 兼容性赛道的相邻成熟项目 | CakeCheck 的输入是场景声明和运行观察，输出是目标覆盖、重放证据和场景契约 |

这两项是必须明确避开的项目。本次改造删除了原来的 API 兼容性、SemVer 和迁移账本源码，
不是只修改标题或 README。

## 相邻但不重合

| 项目 | 公开定位 | CakeCheck 的边界 |
| --- | --- | --- |
| [Luna-Flow/mare_mark](https://github.com/Luna-Flow/mare_mark) | MoonBit payload 的可复现 benchmark、差分验证、调优和报告 | CakeCheck 不测性能、不建立 benchmark 基线；只验证场景行为、目标覆盖和稳定输出证据 |
| [ZQD-ai-nb/mooncake-auditor](https://github.com/ZQD-ai-nb/mooncake-auditor) | README、CI、测试、示例、许可证、提交历史和发布准备度验收 | CakeCheck 不扫描仓库，不给项目 readiness 分数，不替代验收清单 |
| [gywcs101/MoonDocCheck](https://github.com/gywcs101/MoonDocCheck) | 文档注释覆盖、README/示例文档质量和报告 | CakeCheck 不评价文档写作质量，不统计注释覆盖 |
| [LL728/moonseal](https://github.com/LL728/moonseal) | mutation testing、coverage 和测试质量门禁 | CakeCheck 不生成 coverage，不做 mutation testing |
| [Tino-hue/moonmark](https://github.com/Tino-hue/moonmark) | 依赖图、循环依赖、依赖健康和新鲜度 | CakeCheck 不解析依赖图，不评价依赖健康 |
| [EJJ-ai-nb/harborcheck](https://github.com/EJJ-ai-nb/harborcheck) | README 代码证明、第三方来源/许可证证明、身份和验收材料 | CakeCheck 不建立来源档案，不做身份或验收材料归档 |
| [clbbbb/moonbit-license-audit](https://github.com/clbbbb/moonbit-license-audit) | SPDX 许可证元数据审计 | CakeCheck 只记录调用方提供的观察证据，不做许可证识别 |

## CakeCheck 的独立输入和输出

```text
scenario manifest + explicit run observations
  -> scenario/target case validation
  -> coverage and behavior matrix
  -> deterministic schedule and replay envelope
  -> reproduction contract + Markdown/JSON metrics
```

与 API Guard 的区别可以由代码直接验证：当前源码中没有 `api_compatibility.mbt`、
`api_migration.mbt` 或 `semver_analyzer.mbt`；公共入口是
`parse_scenario_manifest`、`build_scenario_matrix`、`build_reproduction_contract` 和
`build_replay_envelopes`。

## 公开检索链接

- [GitHub repository search: moon_api_guard](https://github.com/search?q=moon_api_guard&type=repositories)
- [GitHub repository search: MoonBit API compatibility](https://github.com/search?q=MoonBit+API+compatibility&type=repositories)
- [MoonBit official OSC2026 repository](https://github.com/moonbitlang/OSC2026)
- [MoonBit community repositories](https://github.com/orgs/moonbit-community/repositories)

检索结果会随着报名截止和作品公开继续变化，因此本文件记录的是本次提交前的时间点、
关键词、直接重合对象和主动排除范围。新功能继续扩展时，应重新检索并更新本文件。
