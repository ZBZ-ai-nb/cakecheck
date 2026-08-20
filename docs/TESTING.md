# 测试记录

## 2026-08-20 本地验证

MoonBit 工具链：

```text
moon 0.1.20260724
moonc v0.10.5
```

已通过命令：

```bash
moon check
moon check --deny-warn
moon fmt --check
moon build
moon test
moon test --deny-warn
moon run examples/basic
moon run cmd/main
moon info
git diff --exit-code -- pkg.generated.mbti cmd/main/pkg.generated.mbti examples/basic/pkg.generated.mbti
```

测试结果：

```text
Total tests: 17, passed: 17, failed: 0.
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
- semver prerelease/build metadata 解析和版本 bump 判断；
- Mooncakes 命名空间与 GitHub 仓库一致性；
- README 结构指标、CI workflow 指标和许可证事实；
- Acceptance Evidence 证据矩阵；
- Release Plan 发布命令和阻塞项；
- Quality Matrix 加权质量评分；
- Acceptance Review 最终验收判断。

有效 MoonBit 源码规模：

```text
4,776 non-empty non-comment MoonBit code lines
5,462 total .mbt lines
```

正式发布前请替换 `moon.mod` 中的 owner 与 repository，并执行：

```bash
moon login
moon publish --dry-run
moon publish
```
