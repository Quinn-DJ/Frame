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
