# CakeCheck 项目任务报告书

## 一、基本信息

- 项目名称：CakeCheck：MoonBit 跨目标场景复现矩阵
- 项目定位：场景声明、跨目标观察、证据摘要与可重放契约
- 参赛者：张丙政
- 联系方式：17355718297 / 3525658676@qq.com
- GitHub 仓库：https://github.com/ZBZ-ai-nb/cakecheck
- Mooncakes 包名：ZBZ-ai-nb/cakecheck
- 开源许可证：MIT

## 二、问题背景与选题调整

MoonBit 项目常常同时面向 Native、JavaScript、Wasm 或 Wasm GC。README 中写“示例可运行”
并不能证明命令、目标、输出和耗时边界已经被记录。不同目标的运行结果如果没有稳定场景
编号和证据摘要，维护者很难复现回归，也很难判断一个示例是否只在本机偶然成功。

初审反馈指出，原版本的公共 API 兼容性和 SemVer 主线与公开项目 `moon_api_guard` 直接重合。
本次不是改标题规避，而是从当前版本源码和接口中删除 API 快照比较、SemVer bump、迁移账本
和通用仓库审计主流程，重新收敛为“跨目标场景复现矩阵”。公开检索和排除范围记录在
`docs/COMPETITIVE_SCAN.md`。

## 三、主要功能

1. 解析 `matrix`/`scenario` 场景声明，建立稳定场景 ID；
2. 支持 Native、JavaScript、Wasm、Wasm GC 目标及能力画像；
3. 记录每个场景/目标组合的状态、stdout、stderr、耗时和证据 digest；
4. 检测缺失观察、重复 ID、目标覆盖不足、输出不匹配、超时和缺失证据；
5. 根据策略检查目标覆盖、成功场景输出和证据要求；
6. 生成确定性运行计划，区分 host-bound 与 restricted 调度批次；
7. 生成 replay envelope，提供稳定重放密钥和机器路径脱敏；
8. 生成 Markdown/JSON 矩阵、指标、风险、历史 diff 和复现契约报告；
9. 提供四类内置夹具，覆盖最小 smoke、跨目标、预期失败和受限目标场景。

## 四、工程实现

项目以 MoonBit 为主要实现语言，当前有效 MoonBit 源码约 4311 行，22 个源码文件。

- `model.mbt`：场景、观察、覆盖、契约、指标和调度数据模型；
- `scenario_parser.mbt`：矩阵声明解析和字段诊断；
- `scenario_matrix.mbt`：观察关联、覆盖计算和行为校验；
- `scenario_format.mbt`：观察记录文本/JSON 格式；
- `artifact_digest.mbt`：稳定证据摘要与规范化；
- `scenario_schedule.mbt`：目标批次、顺序和耗时估算；
- `scenario_replay.mbt`：重放封装、密钥和路径脱敏；
- `scenario_contract.mbt`：可复现契约和不变量汇总；
- `scenario_analysis.mbt`、`scenario_metrics.mbt`：可移植性风险和运行指标；
- `scenario_history.mbt`、`scenario_timeline.mbt`：跨版本场景变化记录；
- `examples/basic`、`cmd/main`：可运行示例和 CLI smoke 入口。

核心库为纯数据处理：不读取磁盘、不执行输入命令、不联网、不登录账号、不保存 token。

## 五、差异化与开源合规

已公开检索并对比：`FidollarinLA/moon_api_guard`、`QinXi-ai/moonguard`、
`Luna-Flow/mare_mark`、`ZQD-ai-nb/mooncake-auditor`、`MoonDocCheck`、`MoonSeal`、
`moonmark`、`HarborCheck` 和 `moonbit-license-audit`。本项目不比较 `.mbti` 接口、不做
SemVer 兼容门禁、不做 benchmark、不做通用验收清单、不做文档或许可证审计。

项目使用 MIT 许可证。核心实现、测试、示例和夹具均为原创 MoonBit 代码，不包含复制的
第三方源码、素材、私有代码或来源不明生成内容。

## 六、测试与验收证据

已通过：

```text
moon fmt --check
moon check
moon check --deny-warn
moon build
moon test
moon test --deny-warn: 36 passed, 0 failed
moon run examples/basic
moon run cmd/main
moon info
git diff --check
```

有效 MoonBit 源码约 4311 行；根目录有 MIT LICENSE；README、申报书、设计说明、竞争扫描、
测试记录、更新日志和 CI 配置齐全。GitHub Actions 覆盖格式、检查、构建、测试和两个示例。

## 七、当前状态与后续维护

本报告对应当前本地最终候选版本 `0.3.0`。由于用户明确要求在确认改造完成前不登录 GitHub，
本次本地修改尚未推送，也尚未重新发布 `0.3.0` 到 Mooncakes。后续只需在统一的
`ZBZ-ai-nb` 账号环境提交、推送、检查 CI，并执行 `moon publish --dry-run` 与正式发布。

后续维护方向：增加 runner 适配器、跨机器 artifact 签名、更多宿主能力画像、CI annotation
输出和可选的本地场景文件适配器，同时保持核心库无网络副作用。
