import Foundation

struct Movie: Identifiable, Codable, Sendable, Hashable {
    let id: Int
    let title: String
    let overview: String?
    let releaseDate: String?
    let posterPath: String?
    let backdropPath: String?
    let runtime: Int?
    let voteAverage: Double?
    let voteCount: Int?
    let genres: [Genre]?
    let credits: Credits?
    let videos: VideoResults?
    let tagline: String?
    let status: String?

    var year: String? {
        guard let date = releaseDate, date.count >= 4 else { return nil }
        return String(date.prefix(4))
    }

    var formattedRuntime: String? {
        guard let runtime, runtime > 0 else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
