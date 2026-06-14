import SwiftUI

/// The single source of truth mapping an `AppDestination` to its detail view.
/// Applied once per `NavigationStack` (one per tab) via `withAppDestinations()`,
/// so the 5-case switch lives in exactly one place.
private struct AppDestinationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.navigationDestination(for: AppDestination.self) { destination in
            switch destination {
            case .movie(let id):
                MovieDetailView(movieID: id)
            case .tvShow(let id):
                TVShowDetailView(tvShowID: id)
            case .season(let tvID, let seasonNumber):
                SeasonDetailView(tvID: tvID, seasonNumber: seasonNumber)
            case .episode(let tvID, let seasonNumber, let episodeNumber):
                EpisodeDetailView(tvID: tvID, seasonNumber: seasonNumber, episodeNumber: episodeNumber)
            case .person(let id):
                PersonDetailView(personID: id)
            }
        }
    }
}

extension View {
    func withAppDestinations() -> some View {
        modifier(AppDestinationModifier())
    }
}
