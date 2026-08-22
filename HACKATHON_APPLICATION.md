# CakeCheck 项目申报书

## 基本信息

- 项目名称：CakeCheck：MoonBit 公共 API 迁移契约检查器
- 参赛者：张丙政
- 联系方式：17355718297 / 3525658676@qq.com
- GitHub 仓库：https://github.com/ZBZ-ai-nb/cakecheck
- 项目方向：MoonBit 生态开发工具 / API 迁移账本 / Mooncakes 发布辅助
- 是否为移植项目：否，原创 MoonBit 开源项目
- 开源许可证：MIT

## 项目简介

CakeCheck 面向 MoonBit/Mooncakes 库维护者，读取两个版本的
`pkg.generated.mbti` 公共 API 快照和两个 SemVer 版本，识别新增、删除及同名声明变化，
生成带稳定 ID、风险和动作的 API 迁移账本，再判断版本升级是否准确表达 API 兼容性，并输出可用于 CI 的 Markdown/JSON 发布契约。
它解决“代码构建通过，但版本号与公共 API 漂移不匹配”的具体工程问题。

## 现有基础与本次实现

仓库已有 MoonBit 工程配置、GitHub Actions、MIT 许可证、可运行示例、22 个测试、设计说明、
API 文档和 Mooncakes 发布配置。本次重点实现声明身份匹配、`ApiChange` 变化模型、
`ApiReleaseContract` 版本门禁，以及对低于所需 bump 的发布拒绝。项目保留早期
`AuditReport` 等接口作为 supporting evidence 和已发布包兼容层，不把通用验收清单作为主功能。

## 核心功能与技术方案

- 从 `pkg.generated.mbti` 提取 `pub`/`pub(all)` 声明；
- 为函数、struct、enum、type 和 let 建立稳定身份；
- 区分 added、removed、changed，避免同名类型变化被误报为删除加新增；
- 根据变化推导 same/patch/minor/major 所需等级；
- 比较 `moon.mod` 旧版与新版，输出通过/拒绝的发布契约；
- 生成 `ApiMigrationPlan`，把变化映射为 adopt/migrate/replace 迁移任务；
- 生成 Markdown 和稳定 JSON，适配 CI 日志、artifact 和上层发布脚本。

实现不依赖第三方运行库，不访问网络，不保存账号信息，不自动登录或发布。正式发布仍由维护者
在自己的账号环境执行 MoonBit 官方命令。

## 新颖性与功能边界

公开检索显示，`mooncake-auditor` 已覆盖通用 README/CI/测试/许可证/发布准备度验收；
MoonDocCheck、MoonSeal、moonmark 和 HarborCheck 分别聚焦文档、测试充分性、依赖健康和
来源/身份证据。CakeCheck 的主输入、主输出和判定目标均不同：它只回答公共 API 快照变化
是否匹配 SemVer 发布版本，并额外生成 API 迁移任务账本。完整检索见 `docs/COMPETITIVE_SCAN.md`。

## 测试、文档与维护

测试覆盖新增公开声明、删除声明、同名 struct 变化、迁移任务账本、版本 bump 通过和拒绝、Markdown/JSON
输出，并保留基础工程审计测试。README、`docs/API.md`、`docs/DESIGN.md`、
`docs/DIFFERENTIATION.md`、测试记录、任务报告和更新日志同步说明边界。后续可增加
跨版本快照归档、更多 MoonBit 声明种类和 SARIF 输出。

本项目为原创 MoonBit 实现，不移植第三方源码，不包含来源不明素材或私有代码。规则参考
MoonBit 官方工具链与公开 Mooncakes 发布约定，许可证和来源说明见
`docs/OPEN_SOURCE_COMPLIANCE.md`。
