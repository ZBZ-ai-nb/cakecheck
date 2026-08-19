# CakeCheck 项目申报书

## 基本信息

- 项目名称：CakeCheck：MoonBit/Mooncakes 包发布前质量审计库
- 参赛者：张丙政
- 联系方式：17355718297 / 3525658676@qq.com
- GitHub 仓库链接：https://github.com/ZBZ-ai-nb/cakecheck
- 项目方向：MoonBit 生态开发工具 / Mooncakes 发布质量门禁 / CI 辅助库
- 是否为移植项目：否，原创 MoonBit 开源项目
- 开源许可证：MIT

## 项目简介

CakeCheck 用 MoonBit 实现一个面向 Mooncakes 包发布前自检的审计库，帮助开发者检查 `moon.mod`、README、CI、许可证、提交记录、CHANGELOG 和发布状态等工程完整性。项目提供可复用的数据模型、规则引擎、评分系统、门禁 profile、修复计划、证据矩阵、质量矩阵、发布计划和报告导出能力，能直接服务 MoonBit 包作者、教学验收和开源活动评审。

## 项目方向与适用场景

项目适合 MoonBit 库作者、工具开发者、CI 维护者、课程项目和黑客松验收场景。上层工具将项目文件文本传入 CakeCheck，即可生成结构化检查结果、ready 分数、Markdown 报告和 JSON 摘要。

## 拟实现的核心功能

- 解析并校验 `moon.mod` 必填字段、包名格式、semver、仓库 URL 和许可证字段；
- 检查 README 的安装、用法、示例、测试命令、包名一致性和占位符风险；
- 检查 GitHub Actions 是否覆盖 MoonBit 安装、check、build、test、run；
- 检查 LICENSE、CHANGELOG、仓库公开状态、提交数量和 Mooncakes 发布状态；
- 提供 Quick、Release、Hackathon 三种门禁 profile、修复建议计划和两次审计 diff；
- 提供 README 结构指标、CI workflow 指标、许可证事实、semver 解析、包命名空间一致性和最终验收评审；
- 提供 Markdown/JSON 导出、示例、测试、README、CI 和 Mooncakes 发布配置。

## 项目现有基础与本次计划

当前项目已包含 MoonBit 工程配置、4,776 行非空非注释 MoonBit 源码、测试、示例、README、MIT 许可证、GitHub Actions CI、API 文档、设计说明、测试记录和 Mooncakes 发布字段。GitHub 公开仓库已完成，参赛者还需要登录 Mooncakes，运行验收命令并发布到 mooncakes.io。

## 新颖性与差异化

CakeCheck 聚焦 MoonBit/Mooncakes 包验收质量门禁这一具体生态问题，不是常规算法题、简单示例、通用脚手架或对其他语言项目的重复移植。项目把黑客松验收中分散的工程要求建模为可运行的 MoonBit API，使 README、CI、许可证、命名空间、版本、发布计划和验收证据都能被程序化检查，适合后续扩展为 CI 插件、Web 自查工具或批量包质量仪表盘。

## 原创或参考说明

本项目为原创 MoonBit 实现，不移植第三方源码，不包含来源不明素材或私有代码。项目规则参考 MoonBit 官方工具链文档和 Mooncakes 包发布要求，项目源码采用 MIT 许可证。
