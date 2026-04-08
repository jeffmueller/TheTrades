import Foundation

struct Episode: Identifiable, Codable, Sendable, Hashable {
    let id: Int
    let name: String?
    let overview: String?
    let episodeNumber: Int
    let seasonNumber: Int
    let airDate: String?
    let stillPath: String?
    let voteAverage: Double?
    let runtime: Int?
    let guestStars: [CastMember]?
    let crew: [CrewMember]?

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
