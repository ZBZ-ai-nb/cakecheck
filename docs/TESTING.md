# 测试记录

## 2026-08-24 本地最终候选版本

本次测试对应选题换轨后的 `0.3.0` 候选版本。当前仍未登录 GitHub，代码尚未推送；本文件
只记录本地真实结果，不把未执行的外部动作写成完成。

工具链：

```text
moon 0.1.20260819
moonc v0.10.9
moonrun 0.1.20260819
```

## 验证命令

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
git diff --check
```

结果：

```text
moon fmt --check: pass
moon check: pass
moon check --deny-warn: pass
moon build: pass
moon test: 36 passed, 0 failed
moon test --deny-warn: 36 passed, 0 failed
moon run examples/basic: pass
moon run cmd/main: pass
moon info: pass
git diff --check: pass
```

## 覆盖内容

- `scenario_parser.mbt`：合法矩阵、引号字段、缺失字段、非法目标和超时；
- `scenario_matrix.mbt`：重复 ID、重复观察、缺失观察、目标覆盖、输出和耗时；
- `scenario_format.mbt`：观察记录文本/JSON 解析和序列化；
- `artifact_digest.mbt`：空白规范化、稳定摘要、矩阵摘要和路径无关证据；
- `scenario_policy.mbt`：默认/严格目标策略、输出和 evidence 要求；
- `scenario_schedule.mbt`：目标批次、顺序稳定性、耗时估算和 JSON；
- `scenario_replay.mbt`：重放 key 唯一性、JSON、digest 和机器路径脱敏；
- `scenario_contract.mbt`：矩阵、覆盖、策略、调度、重放和证据不变量；
- `scenario_history.mbt`、`scenario_timeline.mbt`：新增、删除、回归、恢复和趋势；
- `scenario_analysis.mbt`、`scenario_metrics.mbt`：受限目标风险、覆盖率、通过率和目标平衡；
- `scenario_fixtures.mbt`：最小、跨目标、预期失败、Wasm 夹具目录。

## CI 口径

`.github/workflows/ci.yml` 将执行格式、普通检查、严格检查、构建、测试、两个示例和
`moon info`。生成的 `pkg.generated.mbti` 仅用于 MoonBit 工具链接口快照一致性，不是
CakeCheck 的业务输入，也不参与当前项目的功能判定。

## 发布状态

本地 `moon.mod` 已切换到候选版本 `0.3.0`，并已完成本地发布前检查。由于用户要求先完成
本地改造再登录账号，正式 push 和 `moon publish` 留待下一步在统一 `ZBZ-ai-nb` 环境完成。
