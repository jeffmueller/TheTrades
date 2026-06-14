import SwiftUI

@MainActor
@Observable
final class AppState {
    // Per-tab navigation paths so each tab keeps its own back stack.
    var discoverPath = NavigationPath()
    var savedPath = NavigationPath()
    var settingsPath = NavigationPath()
    var selectedTab: AppTab = .discover

    // Discover feed
    var discoverSections: [DiscoverSection] = []
    var isLoadingDiscover = false
    var discoverError: String?

    // Search
    var searchText = ""
    var searchResults: [SearchResult] = []
    var searchFilter: SearchFilter = .all
    var isSearching = false
    var isLoadingMore = false
    var searchError: String?
    private(set) var searchPage = 1
    private(set) var searchTotalPages = 1

    var recentSearches: [String] = []
    var spoilerMode: Bool {
        didSet { store.set(spoilerMode, for: .spoilerMode) }
    }
    var appearance: AppAppearance {
        didSet { store.set(appearance.rawValue, for: .appearance) }
    }

    private let client: any MediaFetching
    private let store: UserDefaultsStore

    init(client: any MediaFetching = TMDBClient.shared, store: UserDefaultsStore = UserDefaultsStore()) {
        self.client = client
        self.store = store
        self.spoilerMode = store.bool(.spoilerMode, default: true)
        self.appearance = store.string(.appearance).flatMap(AppAppearance.init) ?? .system
        self.recentSearches = store.stringArray(.recentSearches)
    }

    // MARK: - Discover

    func loadDiscoverIfNeeded() async {
        guard discoverSections.isEmpty, !isLoadingDiscover else { return }
        await loadDiscover()
    }

    func loadDiscover() async {
        isLoadingDiscover = true
        discoverError = nil
        do {
            async let trending = client.trendingAllWeek(page: 1)
            async let movies = client.popularMovies(page: 1)
            async let tv = client.popularTVShows(page: 1)

            let trendingItems = try await trending.results
            let movieItems = try await movies.results.map { SearchResult.movie($0) }
            let tvItems = try await tv.results.map { SearchResult.tvShow($0) }

            var sections: [DiscoverSection] = []
            if !trendingItems.isEmpty { sections.append(DiscoverSection(title: "Trending This Week", items: trendingItems)) }
            if !movieItems.isEmpty { sections.append(DiscoverSection(title: "Popular Movies", items: movieItems)) }
            if !tvItems.isEmpty { sections.append(DiscoverSection(title: "Popular TV", items: tvItems)) }
            discoverSections = sections
        } catch {
            discoverError = error.localizedDescription
        }
        isLoadingDiscover = false
    }

    // MARK: - Search

    var filteredSearchResults: [SearchResult] {
        searchResults.filter { searchFilter.matches($0) }
    }

    var canLoadMore: Bool {
        searchPage < searchTotalPages
    }

    func search() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            clearSearch()
            return
        }

        isSearching = true
        searchError = nil
        searchPage = 1

        do {
            let response = try await client.searchMulti(query: query, page: 1)
            searchResults = response.results
            searchTotalPages = response.totalPages
            addRecentSearch(query)
        } catch {
            searchError = error.localizedDescription
        }

        isSearching = false
    }

    func loadMoreSearchResults() async {
        guard canLoadMore, !isLoadingMore, !isSearching else { return }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        isLoadingMore = true
        let nextPage = searchPage + 1
        do {
            let response = try await client.searchMulti(query: query, page: nextPage)
            let existingIDs = Set(searchResults.map(\.id))
            searchResults.append(contentsOf: response.results.filter { !existingIDs.contains($0.id) })
            searchPage = nextPage
            searchTotalPages = response.totalPages
        } catch {
            // Keep what we already have; a failed "load more" shouldn't wipe results.
        }
        isLoadingMore = false
    }

    func clearSearch() {
        searchResults = []
        searchError = nil
        searchPage = 1
        searchTotalPages = 1
    }

    // MARK: - Recent Searches

    func addRecentSearch(_ query: String) {
        recentSearches.removeAll { $0.lowercased() == query.lowercased() }
        recentSearches.insert(query, at: 0)
        if recentSearches.count > 20 {
            recentSearches = Array(recentSearches.prefix(20))
        }
        store.set(recentSearches, for: .recentSearches)
    }

    func removeRecentSearch(_ query: String) {
        recentSearches.removeAll { $0 == query }
        store.set(recentSearches, for: .recentSearches)
    }

    func clearRecentSearches() {
        recentSearches = []
        store.remove(.recentSearches)
    }
}
