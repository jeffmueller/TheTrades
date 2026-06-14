import Foundation

/// The subset of TMDB endpoints `AppState` depends on, abstracted so tests can
/// inject a stub instead of hitting the network. `TMDBClient` is the production
/// conformer.
protocol MediaFetching: Sendable {
    func searchMulti(query: String, page: Int) async throws -> PagedResponse<SearchResult>
    func trendingAllWeek(page: Int) async throws -> PagedResponse<SearchResult>
    func popularMovies(page: Int) async throws -> PagedResponse<MovieSearchResult>
    func popularTVShows(page: Int) async throws -> PagedResponse<TVSearchResult>
}

extension TMDBClient: MediaFetching {}
