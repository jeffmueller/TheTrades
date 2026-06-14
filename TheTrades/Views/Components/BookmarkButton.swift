import SwiftUI

/// Toolbar button that toggles whether a `LibraryItem` is in the user's watchlist.
struct BookmarkButton: View {
    let item: LibraryItem
    @Environment(LibraryStore.self) private var library

    private var isSaved: Bool { library.isSaved(item.id) }

    var body: some View {
        Button {
            Haptics.impact(.light)
            withAnimation(.snappy) { library.toggleWatchlist(item) }
        } label: {
            Label(isSaved ? "Saved" : "Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                .symbolRenderingMode(.hierarchical)
                .contentTransition(.symbolEffect(.replace))
        }
        .accessibilityLabel(isSaved ? "Remove from Saved" : "Add to Saved")
    }
}
