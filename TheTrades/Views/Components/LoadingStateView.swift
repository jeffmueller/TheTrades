import SwiftUI

struct LoadingStateView<Content: View>: View {
    let isLoading: Bool
    let error: String?
    let retry: () async -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error {
            ContentUnavailableView {
                Label("Error", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error)
            } actions: {
                Button("Retry") {
                    Task { await retry() }
                }
            }
        } else {
            content()
        }
    }
}
