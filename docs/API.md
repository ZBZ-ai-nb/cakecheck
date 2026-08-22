# API 说明

CakeCheck 的主 API 面向“接口快照变化如何形成迁移任务并匹配发布版本”这一单一工作流。
快照输入来自 MoonBit 的 `moon info`，版本输入来自 `moon.mod` 或发布脚本。

## 快照比较

```moonbit
let compatibility = @audit.analyze_api_compatibility(
  before_snapshot,
  after_snapshot,
)
println(compatibility.summary())
```

比较器只读取以 `pub` 或 `pub(all)` 开头的公共声明。它为每个声明建立稳定身份：

- 函数使用 `fn:名称`；
- 结构体、枚举、类型别名和公开变量使用 `种类:名称`；
- 结构体或枚举的多行内容作为同一个声明比较。

结果字段：

- `added`：新快照中出现、旧快照中没有同名身份的声明；
- `removed`：旧快照中出现、新快照中没有同名身份的声明；
- `changed`：身份相同但完整公开声明内容不同的 `ApiChange`；
- `required_bump`：变化对应的最小版本升级。

当前采用保守发布策略：

| 快照变化 | 最小升级 | 原因 |
| --- | --- | --- |
| 无变化 | same | 只允许保持版本或正常向前发布 |
| 仅新增公开声明 | minor | 新增能力不应破坏已有调用者 |
| 删除声明 | major | 旧调用者可能无法编译 |
| 同名声明内容变化 | major | 签名、字段或公开结构变化可能破坏调用者 |

## API 发布契约

```moonbit
let contract = @audit.build_api_release_contract(
  before_snapshot,
  after_snapshot,
  "0.1.0",
  "0.2.0",
)
if contract.passes() {
  println("release can proceed")
}
```

`ApiReleaseContract` 同时保存：

- `before_version` 与 `after_version`；
- 快照推导出的 `required_bump`；
- 版本号实际推导出的 `declared_bump`；
- `passes`：实际 bump 不低于所需 bump 且版本是有效的向前升级。

版本可以安全地过度升级。例如只新增 API 时使用 major 仍然通过；删除 API 使用 patch 或
minor 则失败。版本回退和非法版本始终失败。

## API 迁移账本

```moonbit
let plan = @audit.build_api_migration_plan(compatibility)
println(plan.to_markdown())
```

`ApiMigrationPlan` 是本项目区别于普通 release checker 的核心对象。它把变化按稳定 ID 编排为：

- `added:...` + `adopt`：新增能力，现有调用者无需迁移；
- `changed:...` + `migrate`：同名公共契约变化，需要审阅调用方；
- `removed:...` + `replace`：删除声明，需要替代入口或迁移说明。

计划同时提供 `breaking_count`、`advisory_count`、风险级别和 JSON/Markdown 输出，
但不扫描下游仓库，也不虚构调用方信息；它只生成维护者可以继续处理的迁移账本。
## 输出

```moonbit
println(contract.to_markdown())
println(contract.to_json())
```

Markdown 用于 CI artifact、Issue 和人工发布审阅；JSON 用于 CI 门禁或上层发布工具。
JSON 只包含稳定摘要字段，不包含路径、网络响应或账号 token。

## 兼容保留 API

项目仍公开 `AuditInput`、`AuditReport`、`EvidenceMatrix`、`ReleasePlan` 等早期接口。
它们用于已有使用者的工程证据和迁移兼容，不改变当前项目的主边界：
CakeCheck 的新增和重点能力是 API 快照漂移、迁移账本与版本发布契约。

这些辅助 API 不会读取磁盘、不执行 GitHub Actions、不登录 GitHub/Mooncakes，也不会自动发布。
