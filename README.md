# Podflow / 播客流

一个**跨平台播客下载与收听工具**，支持 Android 与 Windows。你可以导入 RSS 订阅节目、选择单集下载、自动命名并转码成 mp3/wav/m4a，同时也可以直接把它当作播客 App 来听。

> 状态：🚧 开发中

## 核心功能

- **RSS / OPML 导入**：粘贴单个 RSS 链接，或批量导入 OPML 订阅列表。
- **订阅管理**：保存节目订阅，手动刷新拉取新单集。
- **单集浏览与下载**：查看单集标题、日期、时长、简介，勾选下载。
- **自动命名**：支持 `{title}`、`{show}`、`{ep}`、`{date}` 占位符，默认 `集标题 - 节目名`，可自定义顺序。
- **格式转码**：下载后转码为 mp3 / wav / m4a，基于 ffmpeg。
- **文件组织**：按节目名分文件夹，Windows 与 Android 均可自定义根目录。
- **播放器**：播放本地音频，支持播放/暂停、进度拖动、倍速、睡眠定时、记忆播放位置、mini player。
- **下载管理**：下载中 / 已完成 / 重试 / 队列。
- **分类标签**：给节目或单集打标签，按标签筛选。

## 技术栈

- **Flutter**：一套代码跑 Android + Windows，桌面端优先调试，再上真机。
- **Dart**：业务逻辑、RSS 解析、下载管理。
- **ffmpeg**：音频格式转码（`ffmpeg_kit_flutter`）。
- **GitHub**：每完成一个小功能就 commit + push，作为回滚点。
- **GitHub Actions**：自动打包 Android APK 与 Windows 安装包。

## 开发流程

1. 在 GitHub 记录规格与架构决策（ADR）。
2. 拆小任务（tickets），blockers-first 逐个实现。
3. 每个任务用 TDD：写测试 -> 实现 -> 跑通 -> code review -> commit。
4. 关键节点在 Windows 桌面端和 Android 真机上验证。

## LICENSE

待定。因集成 ffmpeg，LICENSE 需与 ffmpeg 发行版协议兼容（拟采用 GPL-3.0 或按 LGPL 动态链接方案处理）。

## 致谢

UI 风格参考了现有播客 App 的深色卡片与时间线布局，但在配色、图标和交互上做了自己的调整。
