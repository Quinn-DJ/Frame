import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var vm = FrameViewModel()
    @State private var isExporting = false

    var body: some View {
        VStack(spacing: 0) {
            if let preview = vm.previewImage {
                PreviewView(image: preview)

                HStack {
                    Text("底栏比例: \(String(format: "%.0f", vm.barRatio * 100))%")
                    Slider(value: $vm.barRatio, in: 0.10...0.60, step: 0.025)
                        .frame(width: 200)
                        .onChange(of: vm.barRatio) { _, _ in vm.refreshPreview() }

                    Spacer()

                    ExportButton(action: { isExporting = true })
                }
                .padding()
            } else {
                DropZoneView(onImageDropped: { url in vm.processImage(url: url) })
            }

            if vm.isProcessing {
                ProgressView("正在处理…")
                    .scaleEffect(1.2)
                    .padding()
            } else if let errorMsg = vm.errorMessage {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(errorMsg)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .frame(minWidth: 600, minHeight: 500)
        .fileExporter(
            isPresented: $isExporting,
            document: vm.previewImage.flatMap { ImageFileDocument(image: $0) },
            contentType: .jpeg,
            defaultFilename: vm.suggestedExportName
        ) { result in
            switch result {
            case .success(let url):
                vm.export(to: url)
            case .failure(let error):
                vm.errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    ContentView()
}
