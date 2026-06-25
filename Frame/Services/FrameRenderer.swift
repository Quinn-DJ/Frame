import AppKit

struct FrameRenderer {
    static func render(
        photoInfo: PhotoInfo,
        calculator: FrameCalculator,
        barColor: NSColor = .white,
        textColor: NSColor = NSColor(white: 0.30, alpha: 1.0)
    ) -> NSImage {
        let size = calculator.canvasSize
        let result = NSImage(size: size)

        result.lockFocus()

        // 1. 背景（整张画布）
        barColor.setFill()
        NSRect(origin: .zero, size: size).fill()

        // 2. 照片（上方）
        photoInfo.image.draw(in: calculator.photoRect)

        // 3. 底部栏颜色（如果与背景不同，额外覆盖）
        if barColor != .white {
            barColor.setFill()
            calculator.barRect.fill()
        }

        // 4. EXIF 文字（底部栏内居中）
        let exifText = photoInfo.exifSummaryLine
        if !exifText.isEmpty {
            let font = NSFont(name: "Helvetica Neue", size: calculator.fontSize)
                ?? NSFont.systemFont(ofSize: calculator.fontSize)
            let attr: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: textColor,
                .kern: 1.5
            ]
            let attrString = NSAttributedString(string: exifText, attributes: attr)
            attrString.draw(at: calculator.textDrawingOrigin)
        }

        result.unlockFocus()
        return result
    }
}
