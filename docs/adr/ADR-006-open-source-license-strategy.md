# ADR-006: 开源 LICENSE 策略

## 状态

Proposed

## 背景

用户打算将项目开源。项目集成 ffmpeg，其授权协议会影响整个项目的 LICENSE 选择。

## 选项

| 方案 | 说明 | 影响 |
|------|------|------|
| GPL-3.0 | ffmpeg 静态链接进应用 | 整个项目必须 GPL-3.0，代码完全开源 |
| LGPL + 动态链接 | ffmpeg 作为动态库，用户可替换 | 项目可用 MIT/Apache 等宽松协议，但打包复杂 |
| 使用 LGPL 预编译 ffmpeg | ffmpeg_kit_flutter 某些变体是 LGPL | 需确认具体使用的包版本 |

## 决策

待实现 ffmpeg 集成后最终确认。**初步倾向 GPL-3.0**，因为：

1. 用户本来就打算开源，没有闭源需求。
2. GPL-3.0 与 ffmpeg 的 GPL 版本完全兼容，法律风险最低。
3. 静态链接打包最简单，对小白 + AI 开发最友好。

## 理由

- 避免 LGPL 动态链接在 Android APK / Windows 安装包中带来的分发复杂性。
- GPL-3.0 明确、常见，社区接受度高。

## 影响

- 项目代码需采用 GPL-3.0 LICENSE 文件。
- 引用的第三方依赖需检查与 GPL-3.0 兼容。
- 需要在 README 中明确说明 LICENSE。
- 最终确定前需再次核对 `ffmpeg_kit_flutter` 具体发行版的授权条款。
