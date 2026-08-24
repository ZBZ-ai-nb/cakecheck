# API 说明

CakeCheck 的 API 围绕“场景声明 -> 运行观察 -> 目标矩阵 -> 复现证据”这一条工作流。
它不读取文件、不执行命令、不解析公共接口快照，也不访问网络。

## 场景声明

```moonbit
let source = "matrix name=demo version=0.3.0\n" +
  "scenario id=hello title=hello command=\"moon run examples/basic\" " +
  "targets=native,js,wasm expected=success output=\"hello world\" " +
  "timeout_ms=30000 required=true tags=smoke\n"
let manifest = @audit.parse_scenario_manifest(source)
```

每行 `scenario` 可以包含：

- `id`：稳定场景 ID，同一个矩阵中不能重复；
- `title`：人工可读标题；
- `command`：维护者可以复制执行的命令文本；
- `targets`：逗号分隔的 `native`、`js`、`wasm` 或 `wasm-gc`；
- `expected`：`success` 或 `failure`；
- `output`：应出现在 stdout 中的稳定片段；
- `timeout_ms`：正整数超时边界；
- `required`：是否进入验收覆盖；
- `tags`：用于查询的逗号分隔标签。

解析结果是 `ScenarioManifest`，其中 `specs` 保存有效声明，`issues` 保存带代码和修复
提示的解析问题。

## 运行观察

```moonbit
let observation = @audit.ScenarioObservation::{
  id: "hello",
  target: @audit.Native,
  status: @audit.Passed,
  stdout: "hello world",
  stderr: "",
  duration_ms: 14,
  evidence_digest: @audit.scenario_evidence_digest("hello world", ""),
}
```

`ScenarioObservation` 是调用方执行命令后的事实记录。`Passed`、`Failed` 和 `Skipped` 是
运行状态；预期失败场景使用 `expected=failure`，因此“命令失败”本身可以是通过的行为。

观察记录也可以使用文本格式交换：

```moonbit
let text = @audit.observations_to_text([observation])
let parsed = @audit.parse_observation_records(text)
```

## 矩阵校验

```moonbit
let matrix = @audit.build_scenario_matrix(
  manifest,
  [observation],
  [@audit.Native, @audit.Js, @audit.Wasm],
)
let checked = @audit.apply_policy(matrix, @audit.default_matrix_policy())
if checked.passes() {
  println("all required target cases are reproducible")
}
```

矩阵会关联场景和观察，并报告：

- 重复场景 ID 或重复观察；
- 缺少必需观察；
- 观察目标未在场景中声明；
- stdout 不含期望片段；
- 运行耗时超过场景边界；
- 观察缺少 evidence digest；
- 选定目标没有必需场景覆盖。

`ScenarioMatrix::to_markdown()` 和 `to_json()` 输出人工报告与机器数据。

## 策略与目标画像

`default_matrix_policy()` 要求 Native、JavaScript、Wasm 目标至少各有一个必需场景；
`strict_matrix_policy()` 还要求 Wasm GC，并禁止预期失败场景。`target_profile(target)`
说明目标是否支持文件、网络和进程能力，帮助维护者识别把宿主假设带入受限目标的问题。

## 调度、重放与契约

```moonbit
let schedule = @audit.build_schedule(checked)
let replay = @audit.build_replay_envelopes(checked)
let contract = @audit.build_reproduction_contract(
  checked,
  @audit.default_matrix_policy(),
)
println(@audit.schedule_markdown(schedule))
println(@audit.replay_envelopes_to_json(replay))
println(contract.to_markdown())
```

调度器按目标建立稳定批次；重放封装为每个观察生成稳定 `replay_key`，并脱敏常见本机路径；
复现契约汇总矩阵摘要、目标覆盖、调度顺序、重放数量和证据摘要等不变量。

## 查询、历史与指标

`query_scenario_ids` 支持按标签、目标、状态和 `required_only` 查询。`diff_scenario_matrices`
报告新增、删除、回归、恢复和不变场景。`scenario_metrics` 输出目标覆盖率、观察通过率、
耗时区间和目标平衡分数。`analyze_scenario_risks` 则专门标记受限目标中的宿主能力假设。

所有输出都是纯文本或纯数据；库不会替调用方运行命令，也不会声称观察结果来自真实 runner。
