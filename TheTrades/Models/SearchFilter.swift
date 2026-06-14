import Foundation

/// Client-side filter applied to the unified `/search/multi` results.
enum SearchFilter: String, CaseIterable, Identifiable, Hashable {
    case all
    case movies
    case tv
    case people

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .movies: return "Movies"
        case .tv: return "TV"
        case .people: return "People"
        }
    }

    func matches(_ result: SearchResult) -> Bool {
        switch (self, result) {
        case (.all, _): return true
        case (.movies, .movie): return true
        case (.tv, .tvShow): return true
        case (.people, .person): return true
        default: return false
        }
    }
}
