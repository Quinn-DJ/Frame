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
        calculator = FrameCalculator(photoInfo: info)
        if let calc = calculator {
            previewImage = FrameRenderer.render(
                photoInfo: info,
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
        guard let image = previewImage,
              let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.95])
        else { return }
        try? jpegData.write(to: url)
    }
}
