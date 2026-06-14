import Testing
@testable import TheTrades

@MainActor
@Suite struct LibraryStoreTests {

    @Test func togglesWatchlistMembership() {
        let library = LibraryStore(store: makeIsolatedStore())
        let item = LibraryItem.movie(id: 1, title: "Inception", year: "2010", posterPath: nil)

        #expect(library.isSaved(item.id) == false)
        library.toggleWatchlist(item)
        #expect(library.isSaved(item.id))
        #expect(library.watchlist.count == 1)

        library.toggleWatchlist(item)
        #expect(library.isSaved(item.id) == false)
        #expect(library.watchlist.isEmpty)
    }

    @Test func watchlistPersistsAcrossInstances() {
        let store = makeIsolatedStore()
        let library = LibraryStore(store: store)
        let item = LibraryItem.tvShow(id: 1396, name: "Breaking Bad", yearRange: "2008–2013", posterPath: nil)
        library.toggleWatchlist(item)

        let reloaded = LibraryStore(store: store)
        #expect(reloaded.isSaved(item.id))
        #expect(reloaded.watchlist.count == 1)
    }

    @Test func removeFromWatchlist() {
        let library = LibraryStore(store: makeIsolatedStore())
        let item = LibraryItem.person(id: 287, name: "Brad Pitt", department: "Acting", profilePath: nil)
        library.toggleWatchlist(item)
        library.removeFromWatchlist(item)
        #expect(library.watchlist.isEmpty)
    }

    @Test func recentlyViewedDedupesAndOrders() {
        let library = LibraryStore(store: makeIsolatedStore())
        let a = LibraryItem.movie(id: 1, title: "A", year: nil, posterPath: nil)
        let b = LibraryItem.movie(id: 2, title: "B", year: nil, posterPath: nil)

        library.addRecentlyViewed(a)
        library.addRecentlyViewed(b)
        library.addRecentlyViewed(a) // re-view A → moves to front, no duplicate

        #expect(library.recentlyViewed.count == 2)
        #expect(library.recentlyViewed.first?.id == a.id)
    }

    @Test func recentlyViewedCapsAtThirty() {
        let library = LibraryStore(store: makeIsolatedStore())
        for i in 0..<40 {
            library.addRecentlyViewed(LibraryItem.movie(id: i, title: "M\(i)", year: nil, posterPath: nil))
        }
        #expect(library.recentlyViewed.count == 30)
        #expect(library.recentlyViewed.first?.id == "movie-39")
    }

    @Test func clearWatchlistAndRecentlyViewed() {
        let library = LibraryStore(store: makeIsolatedStore())
        library.toggleWatchlist(.movie(id: 1, title: "A", year: nil, posterPath: nil))
        library.addRecentlyViewed(.movie(id: 2, title: "B", year: nil, posterPath: nil))

        library.clearWatchlist()
        library.clearRecentlyViewed()
        #expect(library.watchlist.isEmpty)
        #expect(library.recentlyViewed.isEmpty)
    }
}
