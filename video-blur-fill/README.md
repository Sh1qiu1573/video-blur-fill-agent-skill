# Video Blur-Fill 🎬

批量视频模糊填充转码工具 — 一键将视频输出为多个社交媒体分辨率，多余区域用模糊背景填充。

## ✨ 功能

- 📐 **多分辨率输出**：1280×720 / 1080×1080 / 1080×1350 / 720×1280 四种规格
- 🎨 **模糊底切填充**：非目标比例区域自动用模糊背景补齐，无黑边
- 🔅 **背景压暗**：模糊层亮度 -0.1，让前景主体更突出
- ⚡ **批量处理**：支持拖入多个视频文件一次处理
- 🎯 **单规格模式**：可以只输出某个特定分辨率

## 📦 输出规格

| 名称            | 分辨率   | 比例  | 适用平台        |
|-----------------|----------|-------|-----------------|
| landscape_720p  | 1280×720 | 16:9  | YouTube / 横屏  |
| square_1080p    | 1080×1080| 1:1   | Instagram 方形  |
| portrait_4x5    | 1080×1350| 4:5   | Instagram 竖屏  |
| portrait_9x16   | 720×1280 | 9:16  | 短视频 / Stories|

## 🚀 快速开始

### 前置要求

- [ffmpeg](https://ffmpeg.org/)（命令行可用）

### 基本用法

```bash
# 处理单个视频，输出到当前目录
./batch-blur-fill.sh video.mp4

# 指定输出目录
./batch-blur-fill.sh -o ./output video.mp4

# 只输出方形规格
./batch-blur-fill.sh -r square_1080p video.mp4

# 批量处理
./batch-blur-fill.sh -o ./out *.mp4
```

### 调整画质/速度

```bash
# 更高质量（更慢）
CRF=18 PRESET=slow ./batch-blur-fill.sh video.mp4

# 更快编码（稍低画质）
CRF=28 PRESET=fast ./batch-blur-fill.sh video.mp4
```

## 🎯 技术参数

| 参数       | 默认值 | 说明                         |
|------------|--------|------------------------------|
| boxblur    | 10:5   | 模糊强度（luma:chroma）      |
| brightness | -0.1   | 模糊背景亮度调整             |
| CRF        | 23     | 输出质量（18=高, 28=低）     |
| preset     | medium | 编码速度预设                 |
| 视频编码   | H.264  | libx264                      |
| 音频编码   | AAC    | 128kbps                      |

## 📁 文件结构

```
video-blur-fill/
├── README.md
├── SKILL.md                     # Agent Skill 指令
└── scripts/
    └── batch-blur-fill.sh       # 核心批处理脚本
```

## 🔧 工作原理

```
源视频
  │
  ├─ split ── [bg] 拉伸填满 → 裁剪 → boxblur(10:5) → 亮度-0.1 → 模糊暗底
  │
  └─ split ── [fg] 等比缩放至适配 → 清晰前景
                    │
                    └─ overlay 居中 → 最终输出
```

## 📝 自定义

编辑 `scripts/batch-blur-fill.sh` 中的 `RESOLUTIONS` 数组即可增减输出规格：

```bash
declare -a RESOLUTIONS=(
  "landscape_720p:1280:720"
  "square_1080p:1080:1080"
  "portrait_4x5:1080:1350"
  "portrait_9x16:720:1280"
  # 添加更多…
)
```

## 📄 License

MIT
