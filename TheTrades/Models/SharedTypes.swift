import Foundation

struct Genre: Identifiable, Codable, Sendable, Hashable {
    let id: Int
    let name: String
}

struct PagedResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int
}

struct VideoResults: Codable, Sendable, Hashable {
    let results: [Video]

    /// YouTube trailers and teasers, with trailers ordered first.
    var trailers: [Video] {
        results
            .filter { $0.site == "YouTube" && ($0.type == "Trailer" || $0.type == "Teaser") }
            .sorted { ($0.type == "Trailer" ? 0 : 1) < ($1.type == "Trailer" ? 0 : 1) }
    }
}

struct Video: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String

    var youtubeURL: URL? {
        guard site == "YouTube" else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }

    var thumbnailURL: URL? {
        guard site == "YouTube" else { return nil }
        return URL(string: "https://img.youtube.com/vi/\(key)/hqdefault.jpg")
    }
}
