# 选题差异化说明

## 结论

初审退回指出原项目与 `moon_api_guard` 的核心功能重合。这个判断成立：原版本同时处理
`.mbti` 接口变化、SemVer bump 和发布门禁，与公开 API compatibility guard 属于同一赛道。

当前版本采取实质换轨：删除 API 快照比较、SemVer、迁移账本和通用审计主线，项目改为
“MoonBit 跨目标场景复现矩阵”。主输入是 `scenario` 声明和运行观察，主输出是目标覆盖、
输出证据、确定性调度、重放封装和复现契约。

## 一眼区分

| 维度 | `moon_api_guard` / `moonguard` | CakeCheck 当前版本 |
| --- | --- | --- |
| 输入 | 新旧 `.mbti` 公共接口快照 | 场景声明 + stdout/stderr/耗时/证据摘要 |
| 核心问题 | API 变化是否兼容、版本号是否足够 | 示例是否在声明目标上可复现 |
| 主要判定 | breaking、compatible、SemVer、release blocked | target coverage、output match、timeout、replay contract |
| 主要输出 | API diff、SemVer 建议、CI 门禁、SARIF | scenario matrix、schedule、replay envelope、metrics |
| 是否执行命令 | 由 API Guard CLI 读取接口/目录 | 核心库不执行命令，由 runner 提交观察值 |

## 主动排除

CakeCheck 当前版本明确不做：

- `.mbti` 解析、公共声明 diff 或 API 兼容性判断；
- SemVer bump 推导、发布版本门禁或 API 迁移任务；
- README/CI/许可证/提交历史的通用仓库审计；
- mutation testing、coverage、依赖健康或 benchmark 趋势；
- 网络抓取、GitHub/Mooncakes 登录和自动发布。

这些排除项都写入 README、申报书、设计说明和测试材料，并由当前源码文件结构支持。

## 可核验的新贡献

1. 一个面向场景和目标的简洁声明格式；
2. 一个把声明与运行事实关联起来的 `ScenarioMatrix`；
3. 一个不依赖机器绝对路径的 evidence digest；
4. 一个区分 host-bound/restricted 目标的确定性调度器；
5. 一个带稳定 replay key 的观察封装；
6. 一个把覆盖、调度、重放和策略汇总为不变量的 `ReproductionContract`。

详细链接、检索日期和相邻项目边界见 [`COMPETITIVE_SCAN.md`](COMPETITIVE_SCAN.md)。
