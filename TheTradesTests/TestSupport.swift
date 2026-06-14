import Foundation
@testable import TheTrades

/// A `UserDefaultsStore` backed by a throwaway suite so tests never touch `.standard`.
func makeIsolatedStore() -> UserDefaultsStore {
    let name = "test-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defaults.removePersistentDomain(forName: name)
    return UserDefaultsStore(defaults: defaults)
}

/// A canned `MediaFetching` implementation for driving `AppState` without the network.
struct StubMediaClient: MediaFetching {
    var searchPages: [Int: PagedResponse<SearchResult>] = [:]
    var trending = PagedResponse<SearchResult>(page: 1, results: [], totalPages: 1, totalResults: 0)
    var movies = PagedResponse<MovieSearchResult>(page: 1, results: [], totalPages: 1, totalResults: 0)
    var tv = PagedResponse<TVSearchResult>(page: 1, results: [], totalPages: 1, totalResults: 0)

    func searchMulti(query: String, page: Int) async throws -> PagedResponse<SearchResult> {
        searchPages[page] ?? PagedResponse(page: page, results: [], totalPages: searchPages.keys.max() ?? 1, totalResults: 0)
    }
    func trendingAllWeek(page: Int) async throws -> PagedResponse<SearchResult> { trending }
    func popularMovies(page: Int) async throws -> PagedResponse<MovieSearchResult> { movies }
    func popularTVShows(page: Int) async throws -> PagedResponse<TVSearchResult> { tv }
}

func movieResult(_ id: Int, _ title: String = "Movie") -> SearchResult {
    .movie(MovieSearchResult(id: id, title: title, overview: nil, releaseDate: nil, posterPath: nil, voteAverage: nil))
}

func personResult(_ id: Int, _ name: String = "Person") -> SearchResult {
    .person(PersonSearchResult(id: id, name: name, profilePath: nil, knownForDepartment: nil, knownFor: nil))
}
