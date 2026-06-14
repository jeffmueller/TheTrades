import Foundation

actor TMDBClient {
    static let shared = TMDBClient()

    private let baseURL = "https://api.themoviedb.org/3"
    private let session = URLSession.shared
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private init() {}

    // MARK: - Search

    func searchMulti(query: String, page: Int = 1) async throws -> PagedResponse<SearchResult> {
        try await fetch("/search/multi", queryItems: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "include_adult", value: "false"),
        ])
    }

    // MARK: - Discover

    func trendingAllWeek(page: Int = 1) async throws -> PagedResponse<SearchResult> {
        try await fetch("/trending/all/week", queryItems: [
            URLQueryItem(name: "page", value: String(page)),
        ])
    }

    func popularMovies(page: Int = 1) async throws -> PagedResponse<MovieSearchResult> {
        try await fetch("/movie/popular", queryItems: [
            URLQueryItem(name: "page", value: String(page)),
        ])
    }

    func popularTVShows(page: Int = 1) async throws -> PagedResponse<TVSearchResult> {
        try await fetch("/tv/popular", queryItems: [
            URLQueryItem(name: "page", value: String(page)),
        ])
    }

    // MARK: - Movie

    func movieDetail(id: Int) async throws -> Movie {
        try await fetch("/movie/\(id)", queryItems: [
            URLQueryItem(name: "append_to_response", value: "credits,videos"),
        ])
    }

    // MARK: - TV

    func tvShowDetail(id: Int) async throws -> TVShow {
        try await fetch("/tv/\(id)", queryItems: [
            URLQueryItem(name: "append_to_response", value: "credits,videos"),
        ])
    }

    func seasonDetail(tvID: Int, seasonNumber: Int) async throws -> Season {
        try await fetch("/tv/\(tvID)/season/\(seasonNumber)")
    }

    func episodeDetail(tvID: Int, seasonNumber: Int, episodeNumber: Int) async throws -> Episode {
        try await fetch("/tv/\(tvID)/season/\(seasonNumber)/episode/\(episodeNumber)")
    }

    // MARK: - Person

    func personDetail(id: Int) async throws -> Person {
        try await fetch("/person/\(id)", queryItems: [
            URLQueryItem(name: "append_to_response", value: "movie_credits,tv_credits"),
        ])
    }

    // MARK: - Birthdays (for age-at-release)

    /// Lightweight person response for birthday fetching only.
    private struct PersonBirthday: Decodable, Sendable {
        let id: Int
        let birthday: String?
    }

    /// Fetches birthdays for a list of person IDs in parallel.
    /// Returns a dictionary mapping person ID → birthday string ("yyyy-MM-dd").
    /// Silently skips any person whose fetch fails.
    nonisolated func fetchBirthdays(for personIDs: [Int]) async -> [Int: String] {
        await withTaskGroup(of: (Int, String?).self, returning: [Int: String].self) { group in
            for id in personIDs {
                group.addTask {
                    do {
                        let person: PersonBirthday = try await self.fetch("/person/\(id)")
                        return (id, person.birthday)
                    } catch {
                        return (id, nil)
                    }
                }
            }

            var result: [Int: String] = [:]
            for await (id, birthday) in group {
                if let birthday {
                    result[id] = birthday
                }
            }
            return result
        }
    }

    // MARK: - Private

    private func fetch<T: Decodable & Sendable>(_ path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        var components = URLComponents(string: "\(baseURL)\(path)")
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        guard let url = components?.url else {
            throw TMDBError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(Secrets.tmdbBearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw TMDBError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TMDBError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw TMDBError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw TMDBError.decodingError(error)
        }
    }
}

enum TMDBError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "Server error (HTTP \(statusCode))"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
