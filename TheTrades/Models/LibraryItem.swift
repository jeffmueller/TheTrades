import Foundation

/// A lightweight, persistable reference to something the user has saved or viewed
/// (a movie, TV show, or person). Used for both the Saved watchlist and the
/// Recently Viewed history — `addedAt` records when it entered whichever list holds it.
struct LibraryItem: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let imagePath: String?
    let destination: CodableDestination
    var addedAt: Date

    enum CodableDestination: Codable, Sendable, Hashable {
        case movie(id: Int)
        case tvShow(id: Int)
        case person(id: Int)

        var appDestination: AppDestination {
            switch self {
            case .movie(let id): return .movie(id: id)
            case .tvShow(let id): return .tvShow(id: id)
            case .person(let id): return .person(id: id)
            }
        }

        var typeLabel: String {
            switch self {
            case .movie: return "Movie"
            case .tvShow: return "TV"
            case .person: return "Person"
            }
        }

        var typeIcon: String {
            switch self {
            case .movie: return "film"
            case .tvShow: return "tv"
            case .person: return "person"
            }
        }

        var isPerson: Bool {
            if case .person = self { return true }
            return false
        }
    }

    static func movie(id: Int, title: String, year: String?, posterPath: String?) -> Self {
        Self(
            id: "movie-\(id)",
            title: title,
            subtitle: year,
            imagePath: posterPath,
            destination: .movie(id: id),
            addedAt: Date()
        )
    }

    static func tvShow(id: Int, name: String, yearRange: String?, posterPath: String?) -> Self {
        Self(
            id: "tv-\(id)",
            title: name,
            subtitle: yearRange,
            imagePath: posterPath,
            destination: .tvShow(id: id),
            addedAt: Date()
        )
    }

    static func person(id: Int, name: String, department: String?, profilePath: String?) -> Self {
        Self(
            id: "person-\(id)",
            title: name,
            subtitle: department,
            imagePath: profilePath,
            destination: .person(id: id),
            addedAt: Date()
        )
    }
}
