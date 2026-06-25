import AppKit

struct FrameRenderer {
    static func render(photoInfo: PhotoInfo, calculator: FrameCalculator) -> NSImage {
        let size = calculator.canvasSize
        let result = NSImage(size: size)

        result.lockFocus()

        // 1. 白色背景（整张画布）
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()

        // 2. 照片（上方）
        photoInfo.image.draw(in: calculator.photoRect)

        // 3. EXIF 文字（底部栏内居中）
        let exifText = photoInfo.exifSummaryLine
        if !exifText.isEmpty {
            let font = NSFont(name: "Helvetica Neue", size: calculator.fontSize)
                ?? NSFont.systemFont(ofSize: calculator.fontSize)
            let attr: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor(white: 0.30, alpha: 1.0),
                .kern: 1.5
            ]
            let attrString = NSAttributedString(string: exifText, attributes: attr)
            attrString.draw(at: calculator.textDrawingOrigin)
        }

        result.unlockFocus()
        return result
    }
}
