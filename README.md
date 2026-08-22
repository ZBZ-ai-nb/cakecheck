# CakeCheck：MoonBit 公共 API 迁移契约检查器

[![CI](https://github.com/ZBZ-ai-nb/cakecheck/actions/workflows/ci.yml/badge.svg)](https://github.com/ZBZ-ai-nb/cakecheck/actions/workflows/ci.yml)

CakeCheck 是一个用 MoonBit 实现的公共 API 迁移契约检查器。它读取两个版本的
`pkg.generated.mbti` 接口快照和对应的 SemVer 版本，识别公开声明的新增、删除与同名内容变化，
再判断版本升级是否覆盖了这次 API 漂移，并生成带稳定 ID 的迁移账本。它面向 MoonBit/Mooncakes 库维护者，解决“构建通过了，
但发布版本没有准确表达 API 兼容性”的问题。

## 解决的问题

库作者通常能看到代码差异，却不容易快速确认：

- 哪些公共函数、类型或字段真正新增、删除或改变；
- 一个同名类型的字段变化是否应被当作 breaking change；
- 当前版本号是否满足这次快照变化所需的 major/minor/patch 升级；
- CI 是否可以用一个稳定的 JSON 或 Markdown 契约结果阻止错误发版。

CakeCheck 把这些判断建模为 `ApiCompatibility`、`ApiMigrationPlan` 和 `ApiReleaseContract`，输入是接口快照与版本号，
输出是可读报告和机器可消费的 JSON，不读取网络、不执行仓库中的命令，也不自动发布。

## 安装

`0.2.0` 已使用正确账号提交至 Mooncakes，待服务端构建完成后即可使用：

```bash
moon add ZBZ-ai-nb/cakecheck@0.2.0
```

包名为 `ZBZ-ai-nb/cakecheck`，与 GitHub 仓库和 `moon.mod` 保持一致。

## 最小使用示例

```moonbit
let before = "pub fn parse(String) -> String\n"
let after = before + "pub fn report(String) -> String\n"
let contract = @audit.build_api_release_contract(
  before,
  after,
  "0.1.0",
  "0.2.0",
)
println(contract.summary())
```

新增公开声明需要至少 minor bump；删除声明或同名声明内容变化按保守策略要求 major bump。
版本升级低于所需级别时，`contract.passes()` 返回 `false`。

## API 迁移账本

发布契约之外，`ApiMigrationPlan` 会把变化变成可追踪的迁移任务：新增声明标为 `adopt`，
同名声明变化标为 `migrate`，删除声明标为 `replace`。每项任务都有稳定 ID、风险级别和动作，
可以直接复制到 Issue、变更日志或发布评审记录中；它不扫描仓库，也不假装知道下游代码，
只对公共接口变化给出可解释的迁移提醒。

## 可运行示例

```bash
moon run examples/basic
```

示例会同时展示新增函数、结构体字段变化、major 契约以及 Markdown/JSON 输出。

命令行 smoke 入口：

```bash
moon run cmd/main
```

## 核心 API

```moonbit
pub fn analyze_api_compatibility(
  before : String,
  after : String,
) -> ApiCompatibility

pub fn build_api_release_contract(
  before_snapshot : String,
  after_snapshot : String,
  before_version : String,
  after_version : String,
) -> ApiReleaseContract

pub fn build_api_migration_plan(
  compatibility : ApiCompatibility,
) -> ApiMigrationPlan
```

`ApiCompatibility` 提供：

- `added`：只出现在新快照中的公开声明；
- `removed`：只出现在旧快照中的公开声明；
- `changed`：身份相同但签名或公开结构内容不同的声明；
- `required_bump`：根据变化推导的最小 SemVer 升级；
- `to_markdown()` 和 `summary()`：适合 CI 日志与人工审阅。

`ApiMigrationPlan` 输出 breaking/advisory 数量和迁移任务账本；`ApiReleaseContract` 额外记录旧版本、新版本、实际 bump 和 `passes` 结果，并通过
`to_json()` 输出稳定的自动化接口。

接口快照通常由 MoonBit 工具链生成：

```bash
moon info
```

## 验证

```bash
moon fmt --check
moon check --deny-warn
moon build
moon test --deny-warn
moon run examples/basic
moon run cmd/main
moon info
```

GitHub Actions 会执行格式检查、严格检查、构建、测试、两个示例和生成接口快照校验。

## 功能边界与差异化

CakeCheck 的主功能是“接口快照变化到迁移任务和版本升级”的发布契约，不是通用仓库验收清单。
项目保留了早期的 `AuditReport` 等辅助接口，用于给已有使用者提供基础工程证据，但它们不是本项目
当前的主卖点，也不执行任何账户操作。

本项目明确不做：

- 不替代 `mooncake-auditor` 的 README/CI/测试/许可证/仓库验收清单；
- 不替代 `MoonDocCheck` 的 API 文档注释覆盖率和文档质量报告；
- 不替代 `MoonSeal` 的 mutation testing、coverage 或测试充分性评估；
- 不替代 `moonmark` 的依赖图、依赖健康和新鲜度分析；
- 不替代 `HarborCheck` 的来源证明、身份一致性和验收材料归档；
- 不读取远端仓库，不登录 GitHub/Mooncakes，不自动执行发布。

调研记录和输入/输出边界见 [`docs/COMPETITIVE_SCAN.md`](docs/COMPETITIVE_SCAN.md) 与
[`docs/DIFFERENTIATION.md`](docs/DIFFERENTIATION.md)。

## 许可证

MIT。核心实现为原创 MoonBit 代码，不包含来源不明的第三方代码、素材或数据。
合规说明见 [`docs/OPEN_SOURCE_COMPLIANCE.md`](docs/OPEN_SOURCE_COMPLIANCE.md)。

## 项目资料

- [`docs/API.md`](docs/API.md)：API、快照格式与契约判定规则。
- [`docs/DESIGN.md`](docs/DESIGN.md)：模块职责和设计取舍。
- [`docs/COMPETITIVE_SCAN.md`](docs/COMPETITIVE_SCAN.md)：公开生态重合检索记录。
- [`docs/ACCEPTANCE_SELF_REVIEW.md`](docs/ACCEPTANCE_SELF_REVIEW.md)：验收证据与本地验证。
- [`docs/TESTING.md`](docs/TESTING.md)：测试记录。
- [`HACKATHON_APPLICATION.md`](HACKATHON_APPLICATION.md)：黑客松申报书。
- [`TASK_REPORT.md`](TASK_REPORT.md)：任务报告书。

当前仓库保留 4,000 行以上有效 MoonBit 源码，便于同时展示完整工程实现、测试和可维护性。
