# 选题调研与差异化

Date: 2026-08-20

## 调研结论

MoonBit 生态中已经出现相邻的开源质量工具，例如 [HarborCheck](https://github.com/EJJ-ai-nb/harborcheck)。它的公开说明重点是 README 代码块验证、第三方来源证明、申报身份一致性和维护证据整理，并把这些内容汇总为文档/来源证明报告。

CakeCheck 不复制这些实现，也不把自己定位成 README 代码块验证器或来源证明工具。CakeCheck 的核心边界是 Mooncakes 发布契约：

| 维度 | CakeCheck 的重点 | 明确不做 |
| --- | --- | --- |
| 包元数据 | 解析 `moon.mod`、owner/package、repository、license、SemVer | 不替代 MoonBit 官方解析器 |
| CI 发布门禁 | 检查 `moon check`、`build`、`test`、`run` 和 MoonBit 安装覆盖 | 不执行审计文本中的任意命令 |
| 版本质量 | 比较 `pkg.generated.mbti` 公共 API 快照，识别 breaking change 并建议 major/minor bump | 不生成或修改源码 |
| 发布流程 | 生成 dry-run、验证、tag 和 publish 步骤并列出阻塞项 | 不登录、不保存 token、不自动发布 |
| 质量输出 | 输出 Audit、Evidence、Quality、Release Plan 和 Acceptance Review | 不联网代替远端事实核验 |

## 独立贡献

1. 将 Mooncakes 包名空间、仓库名和发布版本放在同一个可复用模型中检查。
2. 将公共 API 快照变化连接到 SemVer 发布建议，补足“构建通过但版本升级不匹配”的工程风险。
3. 将本地规则结果组织为可消费的 Markdown、JSON、门禁和修复计划，方便接入 CI 或上层 Web 工具。
4. 保持核心实现无外部依赖、无网络副作用，便于评审复现和长期维护。

## 验证证据

- `api_compatibility.mbt`：独立的公共 API 快照比较实现。
- `tests.mbt`：覆盖新增声明、删除声明、兼容性判断和 SemVer bump 建议。
- `docs/API.md`：记录 API 使用边界。
- `docs/DESIGN.md`：记录模块职责和维护方向。

CakeCheck 与相邻工具存在生态问题上的交集，但功能中心、输入模型和输出目标不同；本项目提交时应同时提交本文件，主动说明差异化边界，避免被误解为重复移植或简单改名。
