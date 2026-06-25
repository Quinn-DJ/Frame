# Frame

照片底部信息栏应用 — 拖放照片，在底部叠加纯色 EXIF 信息栏，导出高质量 JPEG。

## 功能

- **拖放导入** — 支持 JPEG、PNG、HEIC、RAW 等格式
- **底部 EXIF 栏** — 图片下方自动生成白栏，显示相机型号、焦距、光圈、快门、ISO
- **栏高可调** — Slider 调节底部栏高度（10%~60%，默认 35% 图片高度）
- **一键导出** — ⌘E 导出 95% 质量 JPEG，文件名自动带 `_framed` 后缀

## 技术栈

- SwiftUI + AppKit（macOS 原生）
- Core Graphics 图片合成（NSImage.lockFocus）
- CGImageSource EXIF 读取
- ObservableObject + Combine 状态管理

## 项目结构

```
Frame/
├── FrameApp.swift               # App 入口
├── ContentView.swift            # 主界面
├── Models/
│   ├── PhotoInfo.swift           # 照片数据模型
│   ├── FrameError.swift          # 错误类型
│   └── ImageFileDocument.swift   # 文件导出
├── Services/
│   ├── ImageLoader.swift         # 图片加载 + EXIF
│   ├── FrameCalculator.swift     # 底部栏/文字算法
│   └── FrameRenderer.swift       # 合成渲染
├── ViewModels/
│   └── FrameViewModel.swift      # 状态管理
└── Views/
    ├── DropZoneView.swift        # 拖放区域
    ├── PreviewView.swift         # 预览
    └── ExportButton.swift        # 导出按钮
```

## 快速开始

1. 在 Xcode 中打开 `Frame.xcodeproj`
2. macOS 26.0+ 部署目标
3. ⌘R 运行
4. 拖一张照片进去试试

## 后续计划

- [ ] 多模版方案（四边白框 Leica 风、暗色栏等）
- [ ] 批量处理
- [ ] 字体 / 导出格式 / 画质选项
