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

    // 缩放生成预览用的缩略版本（CGContext 直接缩放，避免 NSImage.cgImage 不可靠）
    func scaledToFit(maxDimension: CGFloat) -> PhotoInfo {
        let longerSide = max(pixelSize.width, pixelSize.height)
        guard longerSide > maxDimension else { return self }
        let scale = maxDimension / longerSide
        let newWidth = Int(pixelSize.width * scale)
        let newHeight = Int(pixelSize.height * scale)
        let newSize = CGSize(width: newWidth, height: newHeight)

        guard let context = CGContext(
            data: nil,
            width: newWidth,
            height: newHeight,
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: cgImage.bitmapInfo.rawValue
        ) else { return self }

        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(origin: .zero, size: newSize))

        guard let scaledCGImage = context.makeImage() else { return self }

        let scaledImage = NSImage(cgImage: scaledCGImage, size: newSize)

        return PhotoInfo(
            image: scaledImage,
            cgImage: scaledCGImage,
            pixelSize: newSize,
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
