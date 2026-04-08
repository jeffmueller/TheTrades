import Foundation

enum SearchResult: Identifiable, Decodable, Sendable, Hashable {
    case movie(MovieSearchResult)
    case tvShow(TVSearchResult)
    case person(PersonSearchResult)

    var id: String {
        switch self {
        case .movie(let m): return "movie-\(m.id)"
        case .tvShow(let t): return "tv-\(t.id)"
        case .person(let p): return "person-\(p.id)"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case mediaType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mediaType = try container.decode(String.self, forKey: .mediaType)

        switch mediaType {
        case "movie":
            self = .movie(try MovieSearchResult(from: decoder))
        case "tv":
            self = .tvShow(try TVSearchResult(from: decoder))
        case "person":
            self = .person(try PersonSearchResult(from: decoder))
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unknown media_type: \(mediaType)"
                )
            )
        }
    }
}

struct MovieSearchResult: Identifiable, Decodable, Sendable, Hashable {
    let id: Int
    let title: String
    let overview: String?
    let releaseDate: String?
    let posterPath: String?
    let voteAverage: Double?

    var year: String? {
        guard let date = releaseDate, date.count >= 4 else { return nil }
        return String(date.prefix(4))
    }
}

struct TVSearchResult: Identifiable, Decodable, Sendable, Hashable {
    let id: Int
    let name: String
    let overview: String?
    let firstAirDate: String?
    let posterPath: String?
    let voteAverage: Double?

    var year: String? {
        guard let date = firstAirDate, date.count >= 4 else { return nil }
        return String(date.prefix(4))
    }
}

struct PersonSearchResult: Identifiable, Decodable, Sendable, Hashable {
    let id: Int
    let name: String
    let profilePath: String?
    let knownForDepartment: String?
    let knownFor: [SearchResult]?
}
