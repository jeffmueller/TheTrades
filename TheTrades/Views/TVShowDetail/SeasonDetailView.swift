import SwiftUI

struct SeasonDetailView: View {
    let tvID: Int
    let seasonNumber: Int

    @Environment(AppState.self) private var appState
    @State private var season: Season?
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        LoadingStateView(isLoading: isLoading, error: error, retry: loadSeason) {
            if let season {
                List {
                    if let overview = season.overview, !overview.isEmpty {
                        Section {
                            SpoilerGuard {
                                Text(overview)
                                    .font(.body)
                                    .lineSpacing(2)
                            }
                        }
                    }

                    if let episodes = season.episodes, !episodes.isEmpty {
                        Section("Episodes") {
                            ForEach(episodes) { episode in
                                NavigationLink(value: AppDestination.episode(tvID: tvID, seasonNumber: seasonNumber, episodeNumber: episode.episodeNumber)) {
                                    episodeRow(episode)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(season?.name ?? "Season \(seasonNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if season != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: TMDBURLBuilder.season(tvID: tvID, seasonNumber: seasonNumber)) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
        .task { await loadSeason() }
    }

    @ViewBuilder
    private func episodeRow(_ episode: Episode) -> some View {
        HStack(spacing: 14) {
            if appState.spoilerMode {
                PosterImage(url: nil, width: 80, height: 45)
            } else {
                PosterImage(
                    url: ImageURLBuilder.backdropURL(path: episode.stillPath, size: .w300),
                    width: 80,
                    height: 45
                )
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Episode \(episode.episodeNumber)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                if appState.spoilerMode {
                    Text("Episode \(episode.episodeNumber)")
                        .font(.body.weight(.medium))
                } else {
                    Text(episode.name ?? "Episode \(episode.episodeNumber)")
                        .font(.body.weight(.medium))
                        .lineLimit(2)
                }
                HStack(spacing: 8) {
                    if let airDate = episode.airDate {
                        Text(airDate)
                    }
                    if let runtime = episode.formattedRuntime {
                        Text(runtime)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func loadSeason() async {
        isLoading = true
        error = nil
        do {
            season = try await TMDBClient.shared.seasonDetail(tvID: tvID, seasonNumber: seasonNumber)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
