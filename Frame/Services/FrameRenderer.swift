import AppKit
import CoreImage

struct FrameRenderer {
    // Metal GPU 后端 CIContext（单例复用）
    private static let ciContext: CIContext = {
        let options: [CIContextOption: Any] = [
            .useSoftwareRenderer: false,
            .highQualityDownsample: true
        ]
        return CIContext(options: options)
    }()

    static func render(
        photoInfo: PhotoInfo,
        calculator: FrameCalculator,
        barColor: NSColor = .white,
        textColor: NSColor = NSColor(white: 0.30, alpha: 1.0)
    ) -> NSImage {
        let size = calculator.canvasSize
        let canvasRect = CGRect(origin: .zero, size: size)

        // ── Core Image 管线（GPU）──

        // 1. 背景
        let bgColor = CIColor(cgColor: barColor.cgColor)
        let bg = CIImage(color: bgColor).cropped(to: canvasRect)

        // 2. 照片（CI 坐标系原点左下角，照片自然在 canvas 底部）
        let photo = CIImage(cgImage: photoInfo.cgImage)
        let withPhoto = photo.composited(over: bg)

        // 3. EXIF 文字
        let exifText = photoInfo.exifSummaryLine
        var final: CIImage = withPhoto

        if !exifText.isEmpty {
            let textFilter = CIFilter(name: "CITextImageGenerator")!
            textFilter.setValue("Helvetica Neue", forKey: "inputFontName")
            textFilter.setValue(Float(calculator.fontSize), forKey: "inputFontSize")
            textFilter.setValue(exifText, forKey: "inputText")
            textFilter.setValue(2.0, forKey: "inputScaleFactor")

            if let textImage = textFilter.outputImage {
                // 着色：CIFalseColor 将暗色像素映射为 textColor，保持 alpha
                let colorFilter = CIFilter(name: "CIFalseColor")!
                colorFilter.setValue(textImage, forKey: kCIInputImageKey)
                colorFilter.setValue(CIColor(cgColor: textColor.cgColor), forKey: "inputColor0")
                colorFilter.setValue(CIColor(cgColor: textColor.cgColor), forKey: "inputColor1")

                let coloredText = colorFilter.outputImage ?? textImage
                let textExtent = coloredText.extent
                let textX = size.width * 0.075
                // 文字在底部栏中垂直居中（CI 坐标系 y 从底部向上）
                let textY = calculator.photoRect.maxY
                             + (calculator.barHeight - textExtent.height) / 2
                let positionedText = coloredText.transformed(
                    by: CGAffineTransform(translationX: textX, y: textY)
                )
                final = positionedText.composited(over: withPhoto)
            }
        }

        // 4. 限制输出区域为画布尺寸
        final = final.cropped(to: canvasRect)

        // 5. GPU 渲染 → CGImage → NSImage
        guard let cgImage = ciContext.createCGImage(final, from: final.extent) else {
            return NSImage(size: size)
        }

        return NSImage(cgImage: cgImage, size: size)
    }
}
