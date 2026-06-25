import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var vm = FrameViewModel()
    @State private var isExporting = false

    var body: some View {
        VStack(spacing: 0) {
            if let preview = vm.previewImage {
                // 预览区
                PreviewView(image: preview)

                // 设置栏
                HStack {
                    Text("边框比例: \(String(format: "%.1f", vm.borderRatio * 100))%")
                    Slider(value: $vm.borderRatio, in: 0.02...0.08, step: 0.005)
                        .frame(width: 200)
                        .onChange(of: vm.borderRatio) { _, _ in vm.refreshPreview() }

                    Spacer()

                    ExportButton(action: { isExporting = true })
                }
                .padding()
            } else {
                // 空状态 — 拖放区
                DropZoneView(onImageDropped: { url in vm.processImage(url: url) })
            }

            // 加载状态 & 错误提示
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
