import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var vm = FrameViewModel()
    @State private var isExporting = false

    var body: some View {
        VStack(spacing: 0) {
            if let preview = vm.previewImage {
                HStack(spacing: 0) {
                    // 左侧：预览区
                    PreviewView(image: preview)

                    // 右侧：编辑区
                    VStack(alignment: .leading, spacing: 16) {
                        Text("编辑")
                            .font(.headline)

                        Divider()

                        ColorPicker("底部颜色", selection: $vm.barColor)
                            .onChange(of: vm.barColor) { _, _ in vm.refreshPreview() }

                        ColorPicker("文字颜色", selection: $vm.textColor)
                            .onChange(of: vm.textColor) { _, _ in vm.refreshPreview() }

                        Divider()

                        Text("底栏高度：\(String(format: "%.0f", FrameCalculator.barRatio * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        ExportButton(action: { isExporting = true })
                    }
                    .frame(width: 220)
                    .padding()
                }
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
        .frame(minWidth: 800, minHeight: 500)
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
