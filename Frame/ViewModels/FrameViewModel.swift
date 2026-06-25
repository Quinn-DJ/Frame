import Combine
import SwiftUI

@MainActor
class FrameViewModel: ObservableObject {
    @Published var photoInfo: PhotoInfo?
    @Published var calculator: FrameCalculator?
    @Published var previewImage: NSImage?
    @Published var errorMessage: String?
    @Published var isProcessing = false
    @Published var barColor: Color = .white
    @Published var textColor: Color = Color(white: 0.30)

    static let maxPreviewDimension: CGFloat = 1200

    func processImage(url: URL) {
        isProcessing = true
        errorMessage = nil
        do {
            let info = try ImageLoader.load(from: url)
            photoInfo = info
            refreshPreview()
        } catch {
            errorMessage = error.localizedDescription
        }
        isProcessing = false
    }

    func refreshPreview() {
        guard let info = photoInfo else { return }

        // 缩略渲染 — 避免全尺寸 CPU 重绘卡顿
        let previewInfo = info.scaledToFit(maxDimension: Self.maxPreviewDimension)

        calculator = FrameCalculator(photoInfo: previewInfo)
        if let calc = calculator {
            previewImage = FrameRenderer.render(
                photoInfo: previewInfo,
                calculator: calc,
                barColor: NSColor(barColor),
                textColor: NSColor(textColor)
            )
        }
    }

    var suggestedExportName: String {
        guard let url = photoInfo?.sourceURL else { return "framed_photo" }
        let name = url.deletingPathExtension().lastPathComponent
        return "\(name)_framed"
    }

    func export(to url: URL) {
        guard let info = photoInfo else { return }
        let calc = FrameCalculator(photoInfo: info)
        let fullImage = FrameRenderer.render(
            photoInfo: info,
            calculator: calc,
            barColor: NSColor(barColor),
            textColor: NSColor(textColor)
        )
        guard let tiffData = fullImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.95])
        else { return }
        try? jpegData.write(to: url)
    }
}
