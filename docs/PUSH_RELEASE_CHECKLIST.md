# Push And Release Checklist

本清单只用于用户确认身份后的最后操作。本次本地修改期间不需要登录 GitHub Desktop。

## 当前本地状态

- 仓库：`C:\\Users\\11619\\Documents\\Codex\\2026-08-09\\moonbit-readme-ci-mooncakes-io-git-8\\outputs\\mooncake_audit`
- 目标 remote：`https://github.com/ZBZ-ai-nb/cakecheck.git`
- 目标分支：`main`
- 目标账号：`ZBZ-ai-nb`
- 已有公开包：`ZBZ-ai-nb/cakecheck@0.1.0`
- 本次候选版本：`0.2.0`（新增公开 API，至少需要 minor bump）
- 本次改动：仅在本地，等待严格验证和用户确认后再提交/推送。

## 身份安全

- 不在 GitHub Desktop 中切换到其他账号后操作本仓库。
- 不修改全局 Git credential 以“抢救”一次推送。
- 推送前先确认 GitHub Desktop 当前账号确实是 `ZBZ-ai-nb`。
- Mooncakes 发布前单独确认 `moon whoami` 或等价账号信息。
- 不把手机号、邮箱或 token 写入源码、日志和公开 Issue。

## 推送前

```bash
git status
git diff --check
moon fmt --check
moon check --deny-warn
moon build
moon test --deny-warn
moon run examples/basic
moon run cmd/main
moon info
```

确认生成接口快照没有未记录变化：

```bash
git diff --exit-code -- pkg.generated.mbti cmd/main/pkg.generated.mbti examples/basic/pkg.generated.mbti
```

## 正确账号下的外部操作

1. 只在确认 `ZBZ-ai-nb` 身份后创建本地 commit。
2. 通过 GitHub Desktop 或已确认凭据的终端推送 `main`。
3. 检查 GitHub Actions 的新提交是否通过。
4. 若代码版本要与 Mooncakes 同步，更新版本号后执行 `moon publish --dry-run`，
   再在正确 owner 下执行正式发布。
5. 记录新 commit、CI URL、版本号和 Mooncakes 包页面到提交材料。

本仓库不自动执行以上外部动作，以免混用账号。
