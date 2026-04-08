import SwiftUI

@main
struct TheTradesApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appState.navigationPath) {
                SearchView()
                    .navigationDestination(for: AppDestination.self) { destination in
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
            .tint(.primary)
            .environment(appState)
        }
    }
}
