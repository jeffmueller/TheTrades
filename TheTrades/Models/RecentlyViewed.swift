import Foundation

struct RecentlyViewedItem: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let imagePath: String?
    let destination: CodableDestination
    let viewedAt: Date

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
    }

    static func movie(id: Int, title: String, year: String?, posterPath: String?) -> RecentlyViewedItem {
        RecentlyViewedItem(
            id: "movie-\(id)",
            title: title,
            subtitle: year,
            imagePath: posterPath,
            destination: .movie(id: id),
            viewedAt: Date()
        )
    }

    static func tvShow(id: Int, name: String, yearRange: String?, posterPath: String?) -> RecentlyViewedItem {
        RecentlyViewedItem(
            id: "tv-\(id)",
            title: name,
            subtitle: yearRange,
            imagePath: posterPath,
            destination: .tvShow(id: id),
            viewedAt: Date()
        )
    }

    static func person(id: Int, name: String, department: String?, profilePath: String?) -> RecentlyViewedItem {
        RecentlyViewedItem(
            id: "person-\(id)",
            title: name,
            subtitle: department,
            imagePath: profilePath,
            destination: .person(id: id),
            viewedAt: Date()
        )
    }
}
