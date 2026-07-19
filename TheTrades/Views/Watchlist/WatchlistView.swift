import SwiftUI

struct WatchlistView: View {
    @Environment(LibraryStore.self) private var library
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isGrid: Bool { horizontalSizeClass == .regular }

    var body: some View {
        Group {
            if library.watchlist.isEmpty {
                ContentUnavailableView {
                    Label("Nothing Saved Yet", systemImage: "bookmark")
                } description: {
                    Text("Tap the bookmark on any movie, show, or person to save it here.")
                }
            } else if isGrid {
                gridView
            } else {
                listView
            }
        }
        .navigationTitle("Saved")
        .toolbar {
            // The grid removes via context menu, so EditButton has nothing to drive.
            if !library.watchlist.isEmpty, !isGrid {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    private var gridView: some View {
        ScrollView {
            PosterGrid(
                cards: library.watchlist.map { PosterCardModel($0) },
                onRemove: remove
            )
            .padding(.vertical, 20)
        }
    }

    private var listView: some View {
        List {
            ForEach(library.watchlist) { item in
                NavigationLink(value: item.destination.appDestination) {
                    LibraryRow(item: item, posterWidth: 48, posterHeight: 72)
                }
            }
            .onDelete(perform: delete)
        }
        .listStyle(.insetGrouped)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            library.removeFromWatchlist(library.watchlist[index])
        }
    }

    private func remove(_ card: PosterCardModel) {
        guard let item = library.watchlist.first(where: { $0.id == card.id }) else { return }
        library.removeFromWatchlist(item)
    }
}
