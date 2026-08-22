# 测试记录

## 2026-08-21 本地修改后的验证结果

本次修改新增了公共 API 声明级变化和 SemVer 发布契约测试。由于代码尚未推送，
本文件只记录本地验证结果，不把远端 CI 或新版本 Mooncakes 发布写成已完成。

验证命令：

```bash
moon fmt --check
moon check
moon check --deny-warn
moon build
moon test
moon test --deny-warn
moon run examples/basic
moon run cmd/main
moon info
git diff --check
```

结果：

```text
moon fmt --check: pass
moon check --deny-warn: pass
moon build: pass
moon test --deny-warn: 22 passed, 0 failed
moon run examples/basic: pass
moon run cmd/main: pass
moon info: pass
git diff --check: pass
```

新增测试覆盖：

- 新增公开声明推导 minor；
- 删除公开声明推导 major；
- 同名 struct 内容变化归入 `changed` 并推导 major；
- 实际版本满足所需 bump 时契约通过；
- 实际版本低于所需 bump 时契约拒绝；
- API 契约 Markdown/JSON 输出。
- API 迁移账本的稳定 ID、风险级别和 adopt/migrate/replace 动作。

已有测试继续覆盖：

- `moon.mod` 字段解析、重复字段和版本校验；
- README 主题、中文小节和命令覆盖；
- CI 命令、许可证、命名空间和 Mooncakes 元数据；
- 审计报告、门禁、修复计划、证据矩阵、发布计划和验收评审。

## 工具链与历史发布

之前本地环境曾使用：

```text
moon 0.1.20260724
moonc v0.10.5
```

已有 `ZBZ-ai-nb/cakecheck@0.1.0` 发布记录和公开包页面。本次本地代码改变后，
必须在正确的 Mooncakes owner 环境重新执行 dry-run，并根据最终版本发布。
