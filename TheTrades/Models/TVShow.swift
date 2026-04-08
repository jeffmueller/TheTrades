import Foundation

struct TVShow: Identifiable, Codable, Sendable, Hashable {
    let id: Int
    let name: String
    let overview: String?
    let firstAirDate: String?
    let lastAirDate: String?
    let posterPath: String?
    let backdropPath: String?
    let numberOfSeasons: Int?
    let numberOfEpisodes: Int?
    let status: String?
    let genres: [Genre]?
    let seasons: [SeasonSummary]?
    let credits: Credits?
    let tagline: String?

    var firstYear: String? {
        guard let date = firstAirDate, date.count >= 4 else { return nil }
        return String(date.prefix(4))
    }

    var lastYear: String? {
        guard let date = lastAirDate, date.count >= 4 else { return nil }
        return String(date.prefix(4))
    }

    var yearRange: String? {
        guard let first = firstYear else { return nil }
        if status == "Ended" || status == "Canceled" {
            if let last = lastYear, last != first {
                return "\(first)–\(last)"
            }
            return first
        }
        return "\(first)–Present"
    }
}
