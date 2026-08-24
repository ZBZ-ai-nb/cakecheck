# CakeCheck 项目申报书

## 基本信息

- 项目名称：CakeCheck：MoonBit 跨目标场景复现矩阵
- 参赛者：张丙政
- 联系方式：17355718297 / 3525658676@qq.com
- GitHub 仓库：https://github.com/ZBZ-ai-nb/cakecheck
- 项目方向：MoonBit 生态开发工具 / 可复现实例 / 跨目标验证
- 是否为移植项目：否，原创 MoonBit 开源项目
- 开源许可证：MIT

## 项目简介

不同目标下“示例能否运行”经常只停留在 README 的一句话，缺少稳定的场景编号、
明确的期望结果、超时边界和可复核输出。CakeCheck 提供一个纯 MoonBit 的场景声明与
证据矩阵工具：维护者声明命令和目标，运行器记录 stdout、stderr、耗时与证据摘要，
工具校验目标覆盖、输出匹配、重复记录、失败场景和可重放性，并生成 Markdown/JSON 报告。

## 现有基础与本次实现

仓库已有 MoonBit 工程配置、MIT 许可证、GitHub Actions、可运行示例和持续测试基础。
针对初审指出的功能重合风险，本次版本移除了公共 API 快照比较、SemVer 门禁和迁移账本
主线，改为独立的跨目标场景复现工作流。当前实现包含场景解析、观察记录格式、目标能力
画像、覆盖策略、确定性调度、证据摘要、重放封装、风险分析、历史对比、指标和复现契约。

## 核心功能与技术路线

1. 用简洁的 `matrix`/`scenario` 文本声明场景、命令、目标、期望状态、输出片段和超时；
2. 用 `ScenarioObservation` 保存每个场景/目标组合的状态、输出、耗时和 evidence digest；
3. 通过纯函数构建 `ScenarioMatrix`，发现缺失记录、目标覆盖不足、输出不一致和超时；
4. 根据 Native、JavaScript、Wasm、Wasm GC 的能力画像生成确定性运行批次；
5. 生成 replay envelope、Markdown/JSON、目标平衡指标、风险报告和历史 diff；
6. 用 `ReproductionContract` 汇总矩阵、策略、重放密钥和调度顺序，作为 CI artifact 的稳定入口。

项目核心库不读取磁盘、不执行输入命令、不访问网络、不保存 token。命令执行由调用方负责，
因此库本身可以在本地测试、CI runner 或上层 MoonBit 工具中复用。

## 新颖性与差异化

我在 2026-08-24 检索了公开 MoonBit 项目。`FidollarinLA/moon_api_guard` 和
`QinXi-ai/moonguard` 的核心是 `.mbti` 公共 API 兼容性与 SemVer 守护；CakeCheck 当前版本
不解析 `.mbti`、不比较声明、不判断版本升级。`Luna-Flow/mare_mark` 关注可复现 benchmark
和差分验证；CakeCheck 不测性能基线，而是验证“一个具体示例在多个 MoonBit 目标上的行为证据”。
完整检索、链接和排除范围见 `docs/COMPETITIVE_SCAN.md`。

## 预期成果、测试与维护

当前仓库提供 `moon run examples/basic` 和 `moon run cmd/main` 两个可运行示例，36 个测试，
覆盖解析、目标覆盖、失败预期、证据摘要、策略、调度、重放、风险、指标和历史契约。README、
API 说明、设计说明、测试记录、更新日志、CI 和开源合规说明同步维护。后续可增加 runner
适配器、跨机器 artifact 签名、更多宿主能力画像和 CI annotation 输出。

本项目使用 MIT 许可证，核心代码、示例和测试夹具均为原创 MoonBit 实现，不移植第三方源码，
不包含来源不明的素材、私有代码或商业代码。
