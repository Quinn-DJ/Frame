import AppKit

struct PhotoInfo {
    let image: NSImage
    let cgImage: CGImage
    let pixelSize: CGSize           // 原始像素尺寸
    let sourceURL: URL?             // 源文件 URL（用于导出文件名）

    // EXIF 经典四要素
    let cameraModel: String?        // "Leica Q2"
    let focalLength: String?        // "28mm"
    let aperture: String?           // "f/1.7"
    let shutterSpeed: String?       // "1/125"
    let iso: String?                // "ISO 100"

    // 缩放生成预览用的缩略版本
    func scaledToFit(maxDimension: CGFloat) -> PhotoInfo {
        let longerSide = max(pixelSize.width, pixelSize.height)
        guard longerSide > maxDimension else { return self }
        let scale = maxDimension / longerSide
        let newWidth = pixelSize.width * scale
        let newHeight = pixelSize.height * scale
        let newSize = NSSize(width: newWidth, height: newHeight)

        let resized = NSImage(size: newSize)
        resized.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(origin: .zero, size: newSize))
        resized.unlockFocus()

        guard let cgImage = resized.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return self
        }

        return PhotoInfo(
            image: resized,
            cgImage: cgImage,
            pixelSize: CGSize(width: newWidth, height: newHeight),
            sourceURL: sourceURL,
            cameraModel: cameraModel,
            focalLength: focalLength,
            aperture: aperture,
            shutterSpeed: shutterSpeed,
            iso: iso
        )
    }

    // 工具方法
    var exifSummaryLine: String {
        // 单行格式化: "Leica Q2 | 28mm f/1.7 1/125 ISO 100"
        let parts = [cameraModel, focalLength, aperture, shutterSpeed, iso]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        // 相机型号后用 | 分隔，其余用空格
        if parts.count <= 1 { return parts.first ?? "" }
        let model = parts[0]
        let rest = parts.dropFirst().joined(separator: " ")
        return "\(model)  |  \(rest)"
    }
}
