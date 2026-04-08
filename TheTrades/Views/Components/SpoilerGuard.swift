import SwiftUI

struct SpoilerGuard<Content: View>: View {
    @Environment(AppState.self) private var appState
    @State private var revealed = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        if appState.spoilerMode && !revealed {
            content()
                .blur(radius: 10)
                .overlay {
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            revealed = true
                        }
                    } label: {
                        Label("Tap to reveal", systemImage: "eye.slash")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .accessibilityLabel("Hidden for spoiler protection. Tap to reveal.")
        } else {
            content()
        }
    }
}
