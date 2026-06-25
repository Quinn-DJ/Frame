import AppKit

struct FrameCalculator {
    let borderWidth: CGFloat
    let canvasSize: CGSize
    let photoRect: CGRect          // 图片在画布中的位置
    let strokeRect: CGRect         // 细黑描边位置
    let separatorY: CGFloat        // 分隔线 Y 坐标
    let fontSize: CGFloat          // 文字字号
    let textDrawingOrigin: CGPoint // 文字绘制起点

    init(photoInfo: PhotoInfo, borderRatio: CGFloat = 0.04) {
        self.borderWidth = Self.autoBorderWidth(
            imageWidth: photoInfo.pixelSize.width,
            imageHeight: photoInfo.pixelSize.height,
            ratio: borderRatio
        )
        self.canvasSize = CGSize(
            width: photoInfo.pixelSize.width + 2 * borderWidth,
            height: photoInfo.pixelSize.height + 2 * borderWidth
        )
        self.photoRect = CGRect(
            x: borderWidth,
            y: borderWidth,
            width: photoInfo.pixelSize.width,
            height: photoInfo.pixelSize.height
        )
        self.strokeRect = photoRect.insetBy(dx: -1, dy: -1)

        let maxTextWidth = canvasSize.width - borderWidth * 0.3
        let exifText = photoInfo.exifSummaryLine
        self.fontSize = Self.calculateFontSize(
            text: exifText,
            borderWidth: borderWidth,
            maxTextWidth: maxTextWidth
        )

        // 文字在底部边框垂直居中
        let textZoneY = photoInfo.pixelSize.height + borderWidth
        let textZoneHeight = borderWidth
        let font = NSFont(name: "Helvetica Neue", size: fontSize)
            ?? NSFont.systemFont(ofSize: fontSize)
        let lineHeight = font.ascender + abs(font.descender) + font.leading
        let textOriginY = textZoneY + (textZoneHeight - lineHeight) / 2 + font.ascender
        self.textDrawingOrigin = CGPoint(
            x: borderWidth * 0.15 + borderWidth,
            y: textOriginY
        )

        self.separatorY = photoRect.maxY + borderWidth * 0.3
    }

    // MARK: - 自动边框宽度

    /// 根据图片尺寸自动计算边框宽度
    static func autoBorderWidth(
        imageWidth: CGFloat,
        imageHeight: CGFloat,
        ratio: CGFloat = 0.04
    ) -> CGFloat {
        let baseSide = min(imageWidth, imageHeight)
        let minBorder: CGFloat = 40
        let maxBorder: CGFloat = baseSide * 0.08
        let raw = baseSide * ratio
        return max(minBorder, min(raw, maxBorder))
    }

    // MARK: - 文字自适应字号

    /// 计算 EXIF 文字的自适应字号
    static func calculateFontSize(
        text: String,
        borderWidth: CGFloat,
        maxTextWidth: CGFloat,
        fontName: String = "Helvetica Neue"
    ) -> CGFloat {
        guard !text.isEmpty else { return 12 }

        let baseFontSize = borderWidth * 0.28
        let baseFont = NSFont(name: fontName, size: baseFontSize) ?? NSFont.systemFont(ofSize: baseFontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: baseFont]
        let textWidth = (text as NSString).size(withAttributes: attributes).width

        let minFontSize: CGFloat = 8.0
        let maxFontSize: CGFloat = borderWidth * 0.4

        if textWidth > maxTextWidth {
            let scale = maxTextWidth / textWidth
            return max(minFontSize, min(baseFontSize * scale, maxFontSize))
        }

        return max(minFontSize, min(baseFontSize, maxFontSize))
    }
}
