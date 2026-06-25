import AppKit
import UniformTypeIdentifiers

struct ImageLoader {
    static func load(from url: URL) throws -> PhotoInfo {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            throw FrameError.cannotLoadImage
        }
        guard let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw FrameError.cannotLoadImage
        }
        let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]

        let tiff = props?[kCGImagePropertyTIFFDictionary] as? [CFString: Any]
        let exif = props?[kCGImagePropertyExifDictionary] as? [CFString: Any]

        // 相机型号从 TIFF 字典读取
        let cameraModel: String? = {
            if let model = tiff?[kCGImagePropertyTIFFModel] as? String, !model.isEmpty {
                return model
            }
            return nil
        }()

        let shutter = formatShutterSpeed(exif?[kCGImagePropertyExifExposureTime] as? Double)

        return PhotoInfo(
            image: NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height)),
            cgImage: cgImage,
            pixelSize: CGSize(width: cgImage.width, height: cgImage.height),
            sourceURL: url,
            cameraModel: cameraModel,
            focalLength: formatFocalLength(exif?[kCGImagePropertyExifFocalLength] as? Double),
            aperture: formatAperture(exif?[kCGImagePropertyExifFNumber] as? Double),
            shutterSpeed: shutter,
            iso: formatISO(exif?[kCGImagePropertyExifISOSpeedRatings])
        )
    }

    // 快门格式化: 0.008 → "1/125"
    static func formatShutterSpeed(_ value: Double?) -> String? {
        guard let v = value, v > 0 else { return nil }
        if v >= 1 { return "\(Int(v))s" }
        let denominator = Int(round(1.0 / v))
        return "1/\(denominator)"
    }

    // 光圈格式化: 1.7 → "f/1.7"
    static func formatAperture(_ value: Double?) -> String? {
        guard let v = value else { return nil }
        return String(format: "f/%.1f", v)
    }

    // 焦距格式化: 28.0 → "28mm"
    static func formatFocalLength(_ value: Double?) -> String? {
        guard let v = value else { return nil }
        return "\(Int(v))mm"
    }

    // ISO 格式化: [100] → "ISO 100"
    static func formatISO(_ value: Any?) -> String? {
        if let arr = value as? [Int], let v = arr.first { return "ISO \(v)" }
        if let v = value as? Int { return "ISO \(v)" }
        return nil
    }
}
