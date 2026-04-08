import Foundation

enum PosterSize: String, Sendable {
    case w92, w154, w185, w342, w500, w780
}

enum BackdropSize: String, Sendable {
    case w300, w780, w1280
}

enum ProfileSize: String, Sendable {
    case w45, w185, h632
}

enum ImageURLBuilder {
    private static let baseURL = "https://image.tmdb.org/t/p/"

    static func posterURL(path: String?, size: PosterSize = .w342) -> URL? {
        guard let path else { return nil }
        return URL(string: "\(baseURL)\(size.rawValue)\(path)")
    }

    static func backdropURL(path: String?, size: BackdropSize = .w780) -> URL? {
        guard let path else { return nil }
        return URL(string: "\(baseURL)\(size.rawValue)\(path)")
    }

    static func profileURL(path: String?, size: ProfileSize = .w185) -> URL? {
        guard let path else { return nil }
        return URL(string: "\(baseURL)\(size.rawValue)\(path)")
    }
}
