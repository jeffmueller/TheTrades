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
}
