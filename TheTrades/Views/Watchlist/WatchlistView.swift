import SwiftUI

struct WatchlistView: View {
    @Environment(LibraryStore.self) private var library

    var body: some View {
        Group {
            if library.watchlist.isEmpty {
                ContentUnavailableView {
                    Label("Nothing Saved Yet", systemImage: "bookmark")
                } description: {
                    Text("Tap the bookmark on any movie, show, or person to save it here.")
                }
            } else {
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
        }
        .navigationTitle("Saved")
        .toolbar {
            if !library.watchlist.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            library.removeFromWatchlist(library.watchlist[index])
        }
    }
}
