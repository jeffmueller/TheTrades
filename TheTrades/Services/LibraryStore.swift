import SwiftUI

/// Owns the user's saved items (watchlist) and recently-viewed history, persisting
/// both through `UserDefaultsStore`. Kept separate from `AppState` so search/discover
/// state and the user's library evolve independently.
@MainActor
@Observable
final class LibraryStore {
    private(set) var watchlist: [LibraryItem] = []
    private(set) var recentlyViewed: [LibraryItem] = []

    private let store: UserDefaultsStore
    private static let maxRecentlyViewed = 30

    init(store: UserDefaultsStore = UserDefaultsStore()) {
        self.store = store
        self.watchlist = store.codable([LibraryItem].self, for: .watchlist) ?? []
        self.recentlyViewed = store.codable([LibraryItem].self, for: .recentlyViewed) ?? []
    }

    // MARK: - Watchlist

    func isSaved(_ id: String) -> Bool {
        watchlist.contains { $0.id == id }
    }

    func toggleWatchlist(_ item: LibraryItem) {
        if isSaved(item.id) {
            watchlist.removeAll { $0.id == item.id }
        } else {
            var saved = item
            saved.addedAt = Date()
            watchlist.insert(saved, at: 0)
        }
        store.setCodable(watchlist, for: .watchlist)
    }

    func removeFromWatchlist(_ item: LibraryItem) {
        watchlist.removeAll { $0.id == item.id }
        store.setCodable(watchlist, for: .watchlist)
    }

    func clearWatchlist() {
        watchlist = []
        store.remove(.watchlist)
    }

    // MARK: - Recently Viewed

    func addRecentlyViewed(_ item: LibraryItem) {
        recentlyViewed.removeAll { $0.id == item.id }
        recentlyViewed.insert(item, at: 0)
        if recentlyViewed.count > Self.maxRecentlyViewed {
            recentlyViewed = Array(recentlyViewed.prefix(Self.maxRecentlyViewed))
        }
        store.setCodable(recentlyViewed, for: .recentlyViewed)
    }

    func clearRecentlyViewed() {
        recentlyViewed = []
        store.remove(.recentlyViewed)
    }
}
