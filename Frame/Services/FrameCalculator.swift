import AppKit

struct FrameCalculator {
    static let barRatio: CGFloat = 0.12

    let barHeight: CGFloat
    let canvasSize: CGSize
    let photoRect: CGRect
    let barRect: CGRect
    let fontSize: CGFloat
    let textDrawingOrigin: CGPoint

    init(photoInfo: PhotoInfo) {
        let imageWidth = photoInfo.pixelSize.width
        let imageHeight = photoInfo.pixelSize.height

        self.barHeight = imageHeight * Self.barRatio
        self.canvasSize = CGSize(
            width: imageWidth,
            height: imageHeight + barHeight
        )
        self.photoRect = CGRect(
            x: 0,
            y: barHeight,
            width: imageWidth,
            height: imageHeight
        )
        self.barRect = CGRect(
            x: 0,
            y: 0,
            width: imageWidth,
            height: barHeight
        )

        let maxTextWidth = imageWidth * 0.85
        let exifText = photoInfo.exifSummaryLine
        self.fontSize = Self.calculateFontSize(
            text: exifText,
            barHeight: barHeight,
            maxTextWidth: maxTextWidth
        )

        if !exifText.isEmpty {
            let font = NSFont(name: "Helvetica Neue", size: fontSize)
                ?? NSFont.systemFont(ofSize: fontSize)
            let lineHeight = font.ascender + abs(font.descender) + font.leading
            let textY = barHeight / 2 - lineHeight / 2 + font.ascender
            self.textDrawingOrigin = CGPoint(x: imageWidth * 0.075, y: textY)
        } else {
            self.textDrawingOrigin = .zero
        }
    }

    // MARK: - 文字自适应字号

    static func calculateFontSize(
        text: String,
        barHeight: CGFloat,
        maxTextWidth: CGFloat,
        fontName: String = "Helvetica Neue"
    ) -> CGFloat {
        guard !text.isEmpty else { return 12 }

        let baseFontSize = barHeight * 0.25
        let baseFont = NSFont(name: fontName, size: baseFontSize) ?? NSFont.systemFont(ofSize: baseFontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: baseFont]
        let textWidth = (text as NSString).size(withAttributes: attributes).width

        let minFontSize: CGFloat = 10.0
        let maxFontSize: CGFloat = barHeight * 0.45

        if textWidth > maxTextWidth {
            let scale = maxTextWidth / textWidth
            return max(minFontSize, min(baseFontSize * scale, maxFontSize))
        }

        return max(minFontSize, min(baseFontSize, maxFontSize))
    }
}
