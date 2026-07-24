# ADR-001: 选择 Flutter 作为跨平台框架

## 状态

Accepted

## 背景

项目需要同时支持 Android 与 Windows，且要求界面好看、启动快、代码可维护。作为单人 + AI 协作开发，需要选择 AI 熟悉度高、生态成熟、桌面端调试友好的框架。

## 选项

| 选项 | 优点 | 缺点 |
|------|------|------|
| Flutter | 一套代码出 Android + Windows；性能接近原生；UI 可控；AI 训练数据丰富；桌面端便于 AI 闭环调试 | 需要 Dart 学习成本（由 AI 承担） |
| React Native + RNW | JS 生态大 | Windows 端生态较弱，调试坑多 |
| .NET MAUI | C#，Windows 原生支持好 | 跨平台一致性与 UI 精美度不如 Flutter |
| Tauri | 前端技术栈，桌面轻量 | 移动端较新，对小白 + AI 不够稳 |
| Electron | 纯桌面 | 启动慢、包体大，不满足"启动快速" |

## 决策

选择 **Flutter 3.44.8 (stable)**。

## 理由

1. **跨平台一致性最好**：Android 与 Windows 共用一套 Dart 代码，UI 与行为一致。
2. **桌面端优先调试**：Flutter Windows 桌面支持成熟，AI 可以在 Windows 上直接运行、截图、做 golden test，闭环验证 UI。
3. **AI 友好**：Flutter/Dart 文档全、示例多，AI 生成代码准确率高。
4. **性能与 UI**：Skia 自绘，启动快，容易做出好看的深色主题与动画。
5. **打包成熟**：`flutter build apk` 与 `flutter build windows` 都有现成 GitHub Actions 模板。

## 影响

- 项目使用 Dart 语言，依赖包从 pub.dev（国内配置镜像）。
- 开发环境需安装 Android SDK 与 Visual Studio（C++ 桌面工作负载）。
- UI 与业务逻辑主要写在 `lib/` 目录下。
