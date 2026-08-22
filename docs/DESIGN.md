# 设计说明

## 主问题

CakeCheck 不把“仓库是否像一个合格项目”作为主产品，而是处理发布过程中更窄、
更容易被忽略的契约问题：

```
old pkg.generated.mbti + new pkg.generated.mbti
                    + old version + new version
                    -> API change set -> migration ledger -> required SemVer bump -> release decision
```

这条链路只需要纯文本输入，适合在本地、CI 或发布机器人中重复执行，且不会因为网络、
账号状态或仓库结构不同而改变判定。

## 模块职责

- `api_compatibility.mbt`：提取公共声明、建立声明身份、比较新增/删除/改变，并生成发布契约。
- `api_migration.mbt`：将变化转换为稳定 ID、风险级别和 adopt/migrate/replace 迁移动作。
- `semver_analyzer.mbt`：解析和比较 SemVer，提供版本 bump 分类。
- `text.mbt`：ASCII 文本切分、行处理和 JSON 转义等基础能力。
- `report.mbt`：为兼容保留的工程审计结果提供 Markdown/JSON 输出。
- `model.mbt`：兼容保留的审计、证据和质量数据模型。
- `checks.mbt`、`manifest.mbt`、`readme_analyzer.mbt`、`ci_analyzer.mbt`、
  `license_analyzer.mbt`：早期工程证据接口，作为 supporting evidence。
- `examples/basic` 和 `cmd/main`：展示 API 发布契约的可运行入口。

## 声明身份

比较完整声明文本会把同名但内容改变的函数或类型误判为“删除 + 新增”，报告不够适合
发布决策。因此比较器先从声明首行提取身份，再比较同身份声明的完整文本。多行 struct
或 enum 会被作为一个声明收集，字段变化最终出现在 `changed` 中。

这是一个可解释的保守模型，不声称替代 MoonBit 编译器的类型系统。正式发布前仍应运行
`moon check` 和完整测试。

## SemVer 决策

API 变化推导一个最小 bump，实际版本号再推导一个 declared bump。使用等级比较允许
“更高但安全”的版本发布，禁止低于最小 bump 的发布：

```
same < patch < minor < major
```

非法版本和版本回退的等级为 -1，直接失败。这样即使快照比较正确，也不会因为版本字符串
不合法而误放行。

## 非目标

- 不扫描整个仓库来替代通用验收工具；
- 不做公共 API 文档覆盖率统计；
- 不做 mutation testing、coverage 或依赖健康分析；
- 不访问 GitHub/Mooncakes 网络 API；
- 不保存账号信息、不登录、不执行发布命令；
- 不生成源码补丁。

## 维护策略

新增一类公共声明或改变 bump 规则时，必须同时增加：

1. 一个快照输入测试；
2. 一个契约通过或拒绝测试；
3. 一个 README/API 文档示例；
4. 一条 CHANGELOG 记录。

这样可以让功能扩展保持在“API 迁移契约”边界内，不再把项目扩展成泛化的验收平台。
