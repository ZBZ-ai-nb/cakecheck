# Push and Release Checklist

当前候选版本：`0.3.0`

仓库：`https://github.com/ZBZ-ai-nb/cakecheck.git`

## 本地完成

- [x] 主功能已切换为跨目标场景复现矩阵
- [x] 删除 API 兼容性、SemVer 和迁移账本主线
- [x] README、申报书、设计、差异化、测试和合规说明已同步
- [x] `moon fmt --check`
- [x] `moon check --deny-warn`
- [x] `moon build`
- [x] `moon test --deny-warn`
- [x] `moon run examples/basic`
- [x] `moon run cmd/main`
- [x] `moon info`
- [x] `git diff --check`

## 账号动作（暂不执行）

- [ ] 确认 GitHub Desktop 当前仓库为 `cakecheck`、分支为 `main`
- [ ] 只使用 `ZBZ-ai-nb` 账号提交和推送
- [ ] 确认 GitHub Actions 的新提交成功
- [ ] 在同一 Mooncakes owner 环境运行 `moon publish --dry-run`
- [ ] 正式运行 `moon publish`
- [ ] 确认 Mooncakes 公共清单的 `0.3.0` 为 `has_package=true`、`build_status=success`

不要在 `lunemark` 或其他账号窗口提交；不要重复发布旧版本，也不要在未确认身份的环境
执行 push 或 publish。
