# CakeCheck 项目任务报告书

## 一、基本信息

- 项目名称：CakeCheck：MoonBit 公共 API 迁移契约检查器
- 项目定位：接口快照漂移、迁移账本与 SemVer 发布门禁
- 参赛者：张丙政
- 联系方式：17355718297 / 3525658676@qq.com
- GitHub 仓库：https://github.com/ZBZ-ai-nb/cakecheck
- Mooncakes 包名：ZBZ-ai-nb/cakecheck
- 开源许可证：MIT

## 二、项目背景与选题说明

MoonBit 库发布时，`moon check` 和测试通过并不代表版本号表达正确。公共函数、类型或
struct 字段可能已经变化，但维护者仍然发布 patch 或 minor，导致下游用户在升级时遇到
编译失败。CakeCheck 将这个具体风险转化为可重复的纯 MoonBit 检查流程。

初始版本曾把项目描述为通用包验收审计器。经过公开生态检索后，发现该表述与
`mooncake-auditor` 的 README/CI/测试/许可证/发布准备度清单直接重合。因此本次任务
将项目主定位收窄并落实到 API 迁移契约：快照是输入，声明变化是事实，迁移账本是行动清单，
SemVer bump 是发布判定，Markdown/JSON 是输出。通用工程审计只作为兼容保留和 supporting evidence。

## 三、主要功能

1. 读取两个 `pkg.generated.mbti` 文本快照；
2. 提取公共 `pub`/`pub(all)` 声明并建立函数、struct、enum、type、let 的稳定身份；
3. 区分新增、删除和同名内容变化，避免简单文本 diff 产生误报；
4. 根据变化计算 same、patch、minor、major 最小发布等级；
5. 比较旧版本和新版本，生成 `ApiReleaseContract`；
6. 在实际版本低于要求、版本非法或版本回退时拒绝契约；
7. 生成 `ApiMigrationPlan`，将变化映射为稳定 ID、风险和 adopt/migrate/replace 动作；
8. 输出摘要、Markdown 和 JSON，适配 CI 和发布脚本；
9. 保留 `AuditReport`、证据矩阵、发布计划等兼容 API，不改变已发布包的既有使用方式。

## 四、工程实现

项目以 MoonBit 为主要实现语言。核心文件如下：

- `api_compatibility.mbt`：公共声明身份、变化模型和发布契约；
- `api_migration.mbt`：迁移任务、风险级别、动作映射和迁移账本输出；
- `semver_analyzer.mbt`：SemVer 解析、比较和 bump 分类；
- `text.mbt`：快照行处理、标记提取和 JSON 转义；
- `model.mbt`、`report.mbt`：兼容保留的数据模型和报告；
- `examples/basic`、`cmd/main`：API 契约可运行示例；
- `tests.mbt`：快照变化、版本门禁和工程兼容测试。

项目不依赖第三方运行库，不执行输入文本中的命令，不访问网络，不登录 GitHub 或 Mooncakes，
不保存 token，也不自动修改源码。

## 五、差异化核查

已核对的公开相邻项目包括：

- `ZQD-ai-nb/mooncake-auditor`：通用仓库验收；
- `gywcs101/MoonDocCheck`：文档质量；
- `LL728/moonseal`：测试充分性和质量门禁；
- `Tino-hue/moonmark`：依赖健康；
- `EJJ-ai-nb/harborcheck`：来源、身份和验收证据；
- `clbbbb/moonbit-license-audit`：SPDX 许可证元数据。

CakeCheck 不实现上述项目的主功能，只提供 API 快照变化到迁移任务和版本 bump 的发布契约。
完整链接、检索日期和边界见 `docs/COMPETITIVE_SCAN.md` 与 `docs/DIFFERENTIATION.md`。

## 六、测试与验收证据

本地验证命令：

```bash
moon fmt --check
moon check --deny-warn
moon build
moon test --deny-warn
moon run examples/basic
moon run cmd/main
moon info
```

测试覆盖 22 个用例，包括基础审计兼容路径、API 快照新增/删除/改变、迁移账本、SemVer 契约通过和
拒绝、报告导出、README/CI/license 分析和验收证据。当前有效 MoonBit 源码为 4,000 行以上，
代码均对应实际模型、规则、报告、测试或示例。

仓库已配置 GitHub Actions，执行格式检查、严格检查、构建、测试、示例和接口快照校验。
根目录提供 MIT LICENSE；README、设计说明、测试记录、CHANGELOG、申报书和开源合规说明齐全。

## 七、完成状态与维护价值

GitHub 仓库和 Mooncakes 包均使用 `ZBZ-ai-nb/cakecheck`，本地 Git 提交身份统一为张丙政及
报名邮箱。已有公开包版本为 0.1.0；本次修改先在本地完成，未登录 GitHub Desktop、未切换账号、
未推送、未执行 `moon publish`。后续实际提交前应在正确账号环境完成推送，并按新代码版本重新
执行发布检查和 Mooncakes 发布。

后续维护方向：

- 支持更多 `pkg.generated.mbti` 声明形式和公共字段级分类；
- 保存跨版本契约历史并生成变更日志；
- 增加 SARIF/CI annotation 输出；
- 增加可选的本地快照目录适配器，但保持核心库纯函数和无网络副作用。
