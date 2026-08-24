# 设计说明

## 主问题

CakeCheck 处理的是跨目标示例的可复现性，而不是公共接口变化或通用仓库验收：

```text
scenario manifest + run observations
        -> target coverage and behavior checks
        -> schedule + replay evidence
        -> reproduction contract and reports
```

这个边界有三个好处：输入可审阅，核心计算是纯函数，输出可以直接进入 CI artifact；
命令执行仍属于调用方，因此库不会隐藏网络、账号和宿主环境副作用。

## 模块职责

- `model.mbt`：场景、目标、观察、覆盖、策略、调度、重放、契约和指标数据模型；
- `text.mbt`：ASCII 文本、行、带引号 token、CSV、整数、布尔值和 JSON 转义；
- `scenario_parser.mbt`：解析矩阵声明并给出结构化问题；
- `scenario_matrix.mbt`：把观察关联到场景/目标，执行核心行为校验；
- `scenario_format.mbt`：观察记录的文本和 JSON 交换格式；
- `artifact_digest.mbt`：规范化输出并生成确定性证据摘要；
- `target_profiles.mbt`：描述四种目标的文件、网络和进程能力；
- `scenario_policy.mbt`：默认与严格覆盖策略；
- `scenario_schedule.mbt`：按目标建立稳定执行批次并估算耗时；
- `scenario_replay.mbt`：生成稳定重放 key，并消除常见机器路径；
- `scenario_contract.mbt`：把矩阵、策略、调度和重放汇总成显式不变量；
- `scenario_history.mbt`、`scenario_timeline.mbt`：对比跨版本场景结果；
- `scenario_analysis.mbt`、`scenario_metrics.mbt`：可移植性风险与运行指标；
- `scenario_report.mbt`：输出 Markdown/JSON；
- `examples/basic`、`cmd/main`：最小复现与 CLI smoke。

## 纯数据边界

核心包只接受字符串、数组和调用方构造的数据模型。它不会：

- 读取当前工作目录或任意外部文件；
- 执行 `command` 字段中的命令；
- 访问 GitHub、Mooncakes 或其他网络服务；
- 保存 token、账号、绝对路径或机器身份；
- 把声明内容伪装成已执行的观察结果。

这样，`ScenarioMatrix` 的结论只依赖显式输入，runner 可以在 Native、JavaScript 或其他
宿主中独立实现。

## 确定性规则

场景 ID 和目标共同组成 case key：`id@target`。同一 case 只能有一个观察；矩阵遍历顺序
沿用声明顺序，目标调度批次使用固定的 Native、Js、Wasm、WasmGc 顺序。证据摘要先去掉
空行和行首尾空白，再计算稳定 rolling hash；重放 key 还包含命令和期望状态。

## 目标策略

Native 和 JavaScript 被视为 host-bound，因为它们可以连接文件、网络或进程能力；Wasm 和
Wasm GC 视为 restricted，工具会针对命令文本中的明显宿主假设给出风险提示。风险报告是
可解释的维护建议，不替代宿主真实权限检查。

## 失败模型

场景期望值和观察状态分别建模。`expected=success` 要求 `Passed`；`expected=failure` 要求
`Failed`。无论哪种状态，都必须满足输出片段、超时和 evidence digest 约束。缺失必需观察、
重复 ID、重复 observation 和目标覆盖缺口都会生成错误问题。

## 为什么不做 API 兼容性

公开检索确认 `FidollarinLA/moon_api_guard` 与 `QinXi-ai/moonguard` 已经专注 `.mbti` 公共
API 兼容性和 SemVer 门禁。当前 CakeCheck 源码不包含该工作流：不解析 `.mbti`、不比较
声明、不推导版本 bump。这个主动排除是选题差异化的一部分，而不是文档措辞。

## 维护规则

新增场景字段时必须同步增加：

1. 一个合法输入和一个非法输入测试；
2. 一个跨目标或预期失败示例；
3. 一个 Markdown/JSON 证据断言；
4. README、API 说明和 CHANGELOG 更新。

新增 runner 适配器时，适配器必须位于核心纯函数之外，明确记录命令执行、环境变量和
路径脱敏策略。
