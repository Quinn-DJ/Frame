import SwiftUI

struct ExportButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("导出 JPEG", systemImage: "arrow.down.circle")
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .keyboardShortcut("e", modifiers: .command)
    }
}
