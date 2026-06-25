import Foundation

enum FrameError: LocalizedError {
    case cannotLoadImage
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .cannotLoadImage:
            return "无法加载图片。请检查文件格式是否支持。"
        case .exportFailed:
            return "导出失败，请重试。"
        }
    }
}
