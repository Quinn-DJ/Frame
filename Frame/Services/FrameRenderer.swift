import AppKit

struct FrameRenderer {
    static func render(photoInfo: PhotoInfo, calculator: FrameCalculator) -> NSImage {
        let size = calculator.canvasSize
        let result = NSImage(size: size)

        result.lockFocus()

        // 1. 白色背景
        NSColor.white.setFill()
        NSRect(origin: .zero, size: size).fill()

        // 2. 照片
        photoInfo.image.draw(in: calculator.photoRect)

        // 3. 细黑描边（1px，绘制在照片外围）
        NSColor.black.setStroke()
        let path = NSBezierPath(rect: calculator.photoRect)
        path.lineWidth = 0.5
        path.stroke()

        // 4. 浅灰分隔线
        NSColor(white: 0.85, alpha: 1.0).setStroke()
        let sepPath = NSBezierPath()
        let sepLeftX = calculator.borderWidth * 0.3 + calculator.borderWidth
        let sepRightX = size.width - calculator.borderWidth * 0.3 - calculator.borderWidth
        sepPath.move(to: NSPoint(x: sepLeftX, y: calculator.separatorY))
        sepPath.line(to: NSPoint(x: sepRightX, y: calculator.separatorY))
        sepPath.lineWidth = 0.5
        sepPath.stroke()

        // 5. EXIF 文字
        let exifText = photoInfo.exifSummaryLine
        if !exifText.isEmpty {
            let font = NSFont(name: "Helvetica Neue", size: calculator.fontSize)
                ?? NSFont.systemFont(ofSize: calculator.fontSize)
            let attr: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor(white: 0.35, alpha: 1.0),
                .kern: 1.5
            ]
            let attrString = NSAttributedString(string: exifText, attributes: attr)
            attrString.draw(at: calculator.textDrawingOrigin)
        }

        result.unlockFocus()
        return result
    }
}
