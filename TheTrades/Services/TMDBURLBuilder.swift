import Foundation

enum TMDBURLBuilder {
    private static let base = "https://www.themoviedb.org"

    static func movie(id: Int) -> URL {
        URL(string: "\(base)/movie/\(id)")!
    }

    static func tvShow(id: Int) -> URL {
        URL(string: "\(base)/tv/\(id)")!
    }

    static func person(id: Int) -> URL {
        URL(string: "\(base)/person/\(id)")!
    }

    static func season(tvID: Int, seasonNumber: Int) -> URL {
        URL(string: "\(base)/tv/\(tvID)/season/\(seasonNumber)")!
    }

    static func episode(tvID: Int, seasonNumber: Int, episodeNumber: Int) -> URL {
        URL(string: "\(base)/tv/\(tvID)/season/\(seasonNumber)/episode/\(episodeNumber)")!
    }
}
