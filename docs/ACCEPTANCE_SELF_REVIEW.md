# 验收自查报告

日期：2026-08-24
范围：当前本地最终候选版本；未登录 GitHub，未推送，未重新发布 Mooncakes。

## 总体判断

初审退回的核心问题是原项目与 `moon_api_guard` 的功能重合。当前版本已做源码级换轨：
API 快照比较、SemVer 门禁、迁移账本和通用仓库审计文件已从当前包删除；主流程变为
跨目标场景复现矩阵。新功能边界、检索证据和主动排除项见 `README.md`、申报书、
`docs/DESIGN.md` 和 `docs/COMPETITIVE_SCAN.md`。

## 当前本地证据

| 检查项 | 状态 | 证据 |
| --- | --- | --- |
| MoonBit 主实现语言 | Pass | 22 个 `.mbt` 文件，约 4311 行有效源码 |
| README | Pass | 安装、场景格式、观察、报告、示例、验证和边界齐全 |
| 申报书 | Pass | Markdown，一页左右，包含基础、计划、功能、测试、文档、差异化和许可证 |
| 可运行示例 | Pass | `moon run examples/basic`、`moon run cmd/main` |
| 测试 | Pass | `moon test --deny-warn`：36 passed, 0 failed |
| 构建与检查 | Pass | `moon check --deny-warn`、`moon build` |
| 格式与接口 | Pass | `moon fmt --check`、`moon info`、`git diff --check` |
| CI 配置 | Pass locally | `.github/workflows/ci.yml` 覆盖格式、检查、构建、测试和示例 |
| 开源许可证 | Pass | 根目录 MIT LICENSE |
| 功能边界 | Pass | 明确不做 API Guard、通用验收审计、benchmark 和文档质量工具 |
| 公开项目重合检索 | Pass locally | 已记录 `moon_api_guard`、`moonguard`、`mare_mark` 等边界 |
| Git 提交历史 | Pending | 本地已有历史；本次换轨提交尚未推送 |
| GitHub 公开仓库 | Pending | 需要在正确账号完成 push 后确认默认分支 |
| Mooncakes 发布 | Pending | `0.3.0` 需要在正确 owner 环境重新发布 |

## 新主功能证据

```moonbit
let manifest = @audit.parse_scenario_manifest(source)
let matrix = @audit.build_scenario_matrix(manifest, observations, targets)
let contract = @audit.build_reproduction_contract(
  matrix,
  @audit.default_matrix_policy(),
)
contract.is_ready()
```

矩阵会验证场景/目标覆盖、观察状态、输出片段、超时、evidence digest 和策略；契约会
额外汇总重放 key、确定性调度、目标覆盖和证据摘要。

## 重合风险处理

本次不把 API Guard 改成另一个名字。当前源码中没有 `api_compatibility.mbt`、
`api_migration.mbt`、`semver_analyzer.mbt`，README 和申报书也不再把 `.mbti`、SemVer
或 API 变化作为项目功能。与 `moon_api_guard` 的关系被写成明确的非目标，而不是“在其基础上扩展”。

## 提交前剩余动作

1. 在 GitHub Desktop 中只登录/确认 `ZBZ-ai-nb`，切换到 `cakecheck/main`；
2. 提交并推送本地换轨版本；
3. 确认默认分支 CI 成功；
4. 在同一 owner 环境运行 `moon publish --dry-run` 和 `moon publish`；
5. 通过 Mooncakes 公共清单确认 `0.3.0` 已构建成功后再提交验收。

除上述外部动作外，本地代码和材料已完成。不要在未确认账号的环境操作，也不要重复发布旧的
`0.2.0` 版本。
