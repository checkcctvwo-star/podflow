# SPEC：Podflow / 播客流 规格说明

## 1. 项目概述

Podflow 是一个**个人播客下载与收听工具**，目标平台为 **Android** 与 **Windows**。核心定位是：让用户导入 RSS 订阅节目，选择单集下载到本地，自动命名并转码成常用音频格式，同时能直接在 App 内收听。

设计原则：
- **简洁高效**：界面干净，启动快，操作路径短。
- **可回滚开发**：每个功能点独立 commit + push 到 GitHub。
- **桌面优先调试**：Flutter 一套代码，先在 Windows 桌面端验证，再上 Android 真机。
- **开源合规**：UI 参考但不复刻；ffmpeg 使用合规授权方案。

## 2. 目标平台

- Android（真机 + 模拟器）
- Windows 11（桌面端，优先调试平台）

## 3. 功能规格

### 3.1 核心功能（MVP 骨架）

| 功能 | 说明 |
|------|------|
| RSS 导入 | 粘贴 RSS 链接，解析节目信息与单集列表 |
| OPML 导入 | 批量导入 `.opml` 文件中的订阅链接 |
| 订阅管理 | 保存订阅节目，手动刷新检查新单集 |
| 单集浏览 | 节目页 + 单集列表（标题、日期、时长、简介） |
| 选集下载 | 勾选单集，加入下载队列 |
| 下载队列 | 并发数控制、断点续传、暂停/继续/重试 |
| 自动命名 | 基于模板生成文件名，自动清理非法字符 |
| 格式转码 | 下载后转 mp3 / wav / m4a（默认 mp3） |
| 文件组织 | 按节目名分文件夹，根目录可自定义 |
| 播放器 | 播放本地音频，进度、倍速、睡眠定时、记忆位置、mini player |

### 3.2 高级功能（骨架跑通后叠加）

| 功能 | 说明 |
|------|------|
| 分类标签 | 给节目/单集打标签，按标签筛选 |
| 下载管理页 | 下载中 / 已完成 / 重试 / 历史 |
| 设置页 | 命名模板、转码格式与质量、存储路径、主题切换 |
| 自动刷新 | 应用启动或手动触发时检查订阅更新 |
| 播放队列 | 连续播放、上一首/下一首 |

## 4. UI/UX 设计方向

- **主题**：深色模式为主，支持浅色切换。
- **导航**：底部三栏 —— 收听 / 发现 / 我的。
  - **收听**：时间线式 feed，按日期分组展示已下载 / 已订阅节目的单集。
  - **发现**：搜索/导入入口、RSS 链接输入、OPML 导入。
  - **我的**：订阅、下载管理、设置。
- **卡片式布局**：圆角卡片、清晰层级、节目封面 + 标题 + 元信息。
- **参考风格**：参考现有播客 App 的深色卡片与时间线布局，但配色、图标、间距做差异化处理。
- **播放体验**：底部 mini player，点击进入全屏播放页。

## 5. 数据模型

```dart
// 节目订阅
class Subscription {
  final String id;          // uuid 或 rss url hash
  final String feedUrl;     // RSS 链接
  final String title;       // 节目名
  final String? description;
  final String? coverUrl;   // 封面图 URL
  final DateTime addedAt;
}

// 单集
class Episode {
  final String id;
  final String subscriptionId;
  final String title;
  final String? description;
  final DateTime? publishedAt;
  final Duration? duration;
  final String audioUrl;    // 音频下载链接
  final String? coverUrl;
}

// 下载任务
class DownloadTask {
  final String id;
  final String episodeId;
  final DownloadStatus status; // pending / running / paused / completed / failed
  final double progress;
  final String? localPath;  // 本地文件路径
  final String? error;
}
```

## 6. 命名模板规则

默认模板：`{title} - {show}`

可用占位符：
- `{show}` — 节目名
- `{title}` — 单集标题
- `{ep}` — 集数（RSS 中解析，无则空）
- `{date}` — 发布日期（YYYYMMDD）

处理：
- 用户可在设置中调整模板和占位符顺序。
- 文件名非法字符（`\ / : * ? " < > |` 等）自动替换为 `_` 或移除。
- 最终文件名加扩展名（如 `.mp3`）。

## 7. 转码规则

- 使用 ffmpeg 进行音频转码。
- 可选输出格式：mp3、wav、m4a。
- 默认 mp3，默认质量 128kbps（可在设置调整）。
- 转码时机：下载完成后自动执行；转码成功后保留目标格式文件。
- ffmpeg 授权方案需在 ADR 中明确（GPL 静态链接 vs LGPL 动态链接）。

## 8. 文件组织规则

- 根目录可自定义。
- 默认结构：`根目录 / {节目名} / {单集文件}.mp3`
- 节目文件夹名也做非法字符清理。
- Android 上需申请存储权限。

## 9. 关键架构决策（ADR）

| 决策 | 选择 | 理由 |
|------|------|------|
| 跨平台框架 | Flutter | 一套代码出 Android + Windows；性能与 UI 可控；桌面端便于 AI 闭环调试 |
| 转码方案 | ffmpeg_kit_flutter | 成熟封装；需关注授权协议 |
| 数据库 | drift (SQLite) | Flutter 生态成熟，本地持久化订阅/单集/下载状态 |
| 状态管理 | Riverpod / BLoC | 待首版实现时根据复杂度选定 |
| 命名模板 | 占位符 + 用户自定义 | 兼顾默认体验与灵活性 |

## 10. 开发阶段

1. **搭建项目**：GitHub repo、Flutter 环境、项目骨架、首 commit。
2. **RSS/订阅**：解析 RSS、保存订阅、展示节目列表。
3. **单集/下载**：展示单集、下载、命名、转码。
4. **播放器/UI**：播放器、深色主题、参考风格布局。
5. **高级功能**：标签、下载管理页、设置。
6. **CI/打包**：GitHub Actions 打包 APK 与 Windows 安装包。

## 11. 待决策/待确认

- 开源 LICENSE（需与 ffmpeg 授权兼容）。
- 应用英文名/中文名最终确认（当前：Podflow / 播客流）。
- 是否支持后台下载 / 后台播放（第一版建议先不做）。
- 是否支持 OPML 导出（第一版建议先不做，只做导入）。
