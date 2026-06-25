# Frame

极简 Leica 风格白框照片应用 — 拖放照片，自动添加白框和底部 EXIF 信息，导出高质量 JPEG。

## 功能

- **拖放导入** — 支持 JPEG、PNG、HEIC、RAW 等格式
- **自动白框** — 根据图片尺寸智能计算边框宽度（短边 4%，40~8% 区间）
- **EXIF 水印** — 底部白框内显示相机型号、焦距、光圈、快门、ISO
- **实时预览** — 边框比例可调（2%~8%），所见即所得
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
│   ├── FrameCalculator.swift     # 边框/文字算法
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
