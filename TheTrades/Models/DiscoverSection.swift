import Foundation

/// A titled row of media for the Discover home (e.g. "Trending This Week").
struct DiscoverSection: Identifiable, Sendable, Hashable {
    var id: String { title }
    let title: String
    let items: [SearchResult]
}
