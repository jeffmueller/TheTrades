import Foundation

struct Credits: Codable, Sendable, Hashable {
    let cast: [CastMember]
    let crew: [CrewMember]
}

extension Credits {
    /// Crew jobs surfaced (alongside directors) in the detail views.
    static let keyCrewJobs: Set<String> = [
        "Producer", "Writer", "Screenplay", "Director of Photography", "Original Music Composer",
    ]

    var directors: [CrewMember] {
        crew.filter { $0.job == "Director" }
    }

    var keyCrew: [CrewMember] {
        crew.filter { Self.keyCrewJobs.contains($0.job ?? "") }
    }

    /// Unique person IDs to fetch birthdays for: the top `castLimit` cast members,
    /// plus directors and key crew when `includeCrew` is set.
    func personIDs(castLimit: Int = 20, includeCrew: Bool = true) -> [Int] {
        var ids = cast.prefix(castLimit).map(\.id)
        if includeCrew {
            ids += directors.map(\.id) + keyCrew.map(\.id)
        }
        return Array(Set(ids))
    }
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
