# 测试记录

## 2026-08-09 本地验证

MoonBit 工具链：

```text
moon 0.1.20260724
moonc v0.10.5
```

已通过命令：

```bash
moon check
moon build
moon test
moon run examples/basic
moon run cmd/main
```

测试结果：

```text
Total tests: 11, passed: 11, failed: 0.
```

测试覆盖：

- moon.mod 字段解析和重复字段；
- 正常项目 readiness；
- 风险项目错误与警告；
- README 覆盖项；
- 中文 README 小节识别；
- CI 命令覆盖；
- Markdown 与 JSON 导出；
- 评分桶统计；
- Quick、Release、Hackathon 门禁；
- 修复建议计划；
- 两次审计 diff。

正式发布前请替换 `moon.mod` 中的 owner 与 repository，并执行：

```bash
moon login
moon publish --dry-run
moon publish
```
