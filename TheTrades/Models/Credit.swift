import Foundation

struct Credits: Codable, Sendable, Hashable {
    let cast: [CastMember]
    let crew: [CrewMember]
}

struct CastMember: Identifiable, Codable, Sendable, Hashable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
    let order: Int?
}

struct CrewMember: Identifiable, Codable, Sendable, Hashable {
    let id: Int
    let name: String
    let job: String?
    let department: String?
    let profilePath: String?
}

struct PersonCredits: Codable, Sendable, Hashable {
    let cast: [PersonCastCredit]
    let crew: [PersonCrewCredit]
}

struct PersonCastCredit: Identifiable, Codable, Sendable, Hashable {
    let id: Int
    let title: String?
    let name: String?
    let character: String?
    let posterPath: String?
    let releaseDate: String?
    let firstAirDate: String?
    let mediaType: String?
    let voteAverage: Double?
    let voteCount: Int?

    var displayTitle: String {
        title ?? name ?? "Unknown"
    }

    var displayDate: String? {
        releaseDate ?? firstAirDate
    }

    var year: String? {
        guard let date = displayDate, date.count >= 4 else { return nil }
        return String(date.prefix(4))
    }
}

struct PersonCrewCredit: Identifiable, Codable, Sendable, Hashable {
    let id: Int
    let title: String?
    let name: String?
    let job: String?
    let department: String?
    let posterPath: String?
    let releaseDate: String?
    let firstAirDate: String?
    let mediaType: String?

    var displayTitle: String {
        title ?? name ?? "Unknown"
    }

    var displayDate: String? {
        releaseDate ?? firstAirDate
    }

    var year: String? {
        guard let date = displayDate, date.count >= 4 else { return nil }
        return String(date.prefix(4))
    }
}
