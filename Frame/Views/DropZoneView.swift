import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    let onImageDropped: (URL) -> Void
    @State private var isHovering = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isHovering ? Color.accentColor : Color.gray.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                )
                .background(Color.gray.opacity(0.05))

            VStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                Text("拖放照片到这里")
                    .font(.title3)
                Text("支持 JPEG、PNG、HEIC、RAW 等格式")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(40)
        .onDrop(of: [.fileURL], isTargeted: $isHovering) { providers in
            guard let provider = providers.first else { return false }
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { data, _ in
                if let data = data as? Data,
                   let url = URL(dataRepresentation: data, relativeTo: nil) {
                    DispatchQueue.main.async { onImageDropped(url) }
                }
            }
            return true
        }
    }
}
