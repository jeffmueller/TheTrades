import SwiftUI

@MainActor
@Observable
final class AppState {
    var navigationPath = NavigationPath()
    var searchText = ""
    var searchResults: [SearchResult] = []
    var isSearching = false
    var searchError: String?
    var recentSearches: [String] = []
    var recentlyViewed: [RecentlyViewedItem] = []
    var spoilerMode: Bool {
        didSet { UserDefaults.standard.set(spoilerMode, forKey: "spoilerMode") }
    }

    private static let maxRecentlyViewed = 30

    init() {
        self.spoilerMode = UserDefaults.standard.object(forKey: "spoilerMode") as? Bool ?? true
        self.recentSearches = UserDefaults.standard.stringArray(forKey: "recentSearches") ?? []
        self.recentlyViewed = Self.loadRecentlyViewed()
    }

    // MARK: - Search

    func search() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            clearSearch()
            return
        }

        isSearching = true
        searchError = nil

        do {
            let response = try await TMDBClient.shared.searchMulti(query: query)
            searchResults = response.results
            addRecentSearch(query)
        } catch {
            searchError = error.localizedDescription
        }

        isSearching = false
    }

    func clearSearch() {
        searchResults = []
        searchError = nil
    }

    // MARK: - Recent Searches

    func addRecentSearch(_ query: String) {
        recentSearches.removeAll { $0.lowercased() == query.lowercased() }
        recentSearches.insert(query, at: 0)
        if recentSearches.count > 20 {
            recentSearches = Array(recentSearches.prefix(20))
        }
        UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
    }

    func removeRecentSearch(_ query: String) {
        recentSearches.removeAll { $0 == query }
        UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
    }

    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: "recentSearches")
    }

    // MARK: - Recently Viewed

    func addRecentlyViewed(_ item: RecentlyViewedItem) {
        recentlyViewed.removeAll { $0.id == item.id }
        recentlyViewed.insert(item, at: 0)
        if recentlyViewed.count > Self.maxRecentlyViewed {
            recentlyViewed = Array(recentlyViewed.prefix(Self.maxRecentlyViewed))
        }
        saveRecentlyViewed()
    }

    func clearRecentlyViewed() {
        recentlyViewed = []
        UserDefaults.standard.removeObject(forKey: "recentlyViewed")
    }

    private func saveRecentlyViewed() {
        if let data = try? JSONEncoder().encode(recentlyViewed) {
            UserDefaults.standard.set(data, forKey: "recentlyViewed")
        }
    }

    private static func loadRecentlyViewed() -> [RecentlyViewedItem] {
        guard let data = UserDefaults.standard.data(forKey: "recentlyViewed"),
              let items = try? JSONDecoder().decode([RecentlyViewedItem].self, from: data) else {
            return []
        }
        return items
    }
}
