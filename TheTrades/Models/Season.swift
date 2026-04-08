import Foundation

struct SeasonSummary: Identifiable, Codable, Sendable, Hashable {
    let id: Int
    let seasonNumber: Int
    let name: String?
    let overview: String?
    let posterPath: String?
    let episodeCount: Int?
    let airDate: String?

    var year: String? {
        guard let date = airDate, date.count >= 4 else { return nil }
        return String(date.prefix(4))
    }
}

struct Season: Identifiable, Codable, Sendable, Hashable {
    let id: Int
    let seasonNumber: Int
    let name: String?
    let overview: String?
    let posterPath: String?
    let airDate: String?
    let episodes: [Episode]?

    // Unique ID combining the underscore-separated ids
    // since TMDB season IDs can collide across shows
    var uniqueID: String {
        "\(id)-\(seasonNumber)"
    }
}
