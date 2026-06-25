import SwiftUI
import UniformTypeIdentifiers

struct ImageFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.jpeg, .png, .tiff] }
    let image: NSImage

    init(image: NSImage) { self.image = image }

    init(configuration: ReadConfiguration) throws {
        throw FrameError.exportFailed
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.95])
        else {
            throw FrameError.exportFailed
        }
        return FileWrapper(regularFileWithContents: data)
    }
}
