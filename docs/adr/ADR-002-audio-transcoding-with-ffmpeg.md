# ADR-002: 使用 ffmpeg 进行音频转码

## 状态

Accepted

## 背景

用户要求下载的音频可转换为 mp3 / wav / m4a 三种格式。跨平台音频转码最成熟的方案是 ffmpeg。

## 选项

| 选项 | 优点 | 缺点 |
|------|------|------|
| ffmpeg_kit_flutter | 成熟封装，同时支持 Android / iOS / macOS / Linux / Windows | 项目已归档（archived），但仍可用；需关注授权协议 |
| 原生平台 API 分别实现 | 无 ffmpeg 授权问题 | 工作量大，Android/Windows 需要两套代码 |
| 云端转码 | 不占用本地资源 | 需要服务器、网络依赖、成本高、隐私差 |

## 决策

选择 **`ffmpeg_kit_flutter`** 作为 ffmpeg 的 Flutter 封装。

## 理由

1. **跨平台**：一套 API 同时覆盖 Android 与 Windows。
2. **成熟**：经过多年生产环境验证，API 稳定。
3. **格式全**：mp3、wav、m4a 都支持。
4. **AI 可控**：命令行式 API，易于生成和测试。

## 影响

- 需处理 ffmpeg 授权问题（详见 ADR-006）。
- 应用包体会增大（包含 ffmpeg 二进制）。
- 转码是 CPU 密集型操作，需在下载完成后异步执行，避免阻塞 UI。
- 默认输出 mp3 128kbps，用户可在设置中调整格式与质量。
