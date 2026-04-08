import Foundation

enum AppDestination: Hashable {
    case movie(id: Int)
    case tvShow(id: Int)
    case season(tvID: Int, seasonNumber: Int)
    case episode(tvID: Int, seasonNumber: Int, episodeNumber: Int)
    case person(id: Int)
}
