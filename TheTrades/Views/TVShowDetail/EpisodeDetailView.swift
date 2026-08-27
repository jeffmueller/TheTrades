import SwiftUI
import NukeUI

struct EpisodeDetailView: View {
    let tvID: Int
    let seasonNumber: Int
    let episodeNumber: Int

    @State private var episode: Episode?
    @State private var birthdays: [Int: String] = [:]
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        LoadingStateView(isLoading: isLoading, error: error, retry: loadEpisode) {
            if let episode {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        SpoilerGuard {
                            LazyImage(url: ImageURLBuilder.backdropURL(path: episode.stillPath)) { state in
                                if let image = state.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Rectangle()
                                        .fill(.quaternary)
                                        .aspectRatio(16 / 9, contentMode: .fit)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .aspectRatio(16 / 9, contentMode: .fit)
                            .clipped()
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("S\(seasonNumber) E\(episodeNumber)")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                                SpoilerGuard {
                                    Text(episode.name ?? "Episode \(episodeNumber)")
                                        .font(.title2.bold())
                                }
                                HStack(spacing: 10) {
                                    if let airDate = episode.airDate {
                                        Text(airDate)
                                    }
                                    if let runtime = episode.formattedRuntime {
                                        Text(runtime)
                                    }
                                    if let rating = episode.voteAverage, rating > 0 {
                                        HStack(spacing: 3) {
                                            Image(systemName: "star.fill")
                                                .font(.caption)
                                            Text(String(format: "%.1f", rating))
                                        }
                                    }
                                }
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }

                            if let overview = episode.overview, !overview.isEmpty {
                                SpoilerGuard {
                                    Text(overview)
                                        .font(.body)
                                        .lineSpacing(2)
                                }
                            }

                            if let guestStars = episode.guestStars, !guestStars.isEmpty {
                                DetailSection(title: "Guest Stars") {
                                    ForEach(guestStars) { member in
                                        CastRow(
                                            id: member.id, name: member.name, role: member.character,
                                            profilePath: member.profilePath,
                                            ageAtRelease: AgeCalculator.age(birthday: birthdays[member.id], at: episode.airDate)
                                        )
                                    }
                                }
                            }

                            if let crew = episode.crew, !crew.isEmpty {
                                DetailSection(title: "Crew") {
                                    ForEach(crew) { member in
                                        CastRow(
                                            id: member.id, name: member.name, role: member.job,
                                            profilePath: member.profilePath,
                                            ageAtRelease: AgeCalculator.age(birthday: birthdays[member.id], at: episode.airDate)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Episode \(episodeNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if episode != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: TMDBURLBuilder.episode(tvID: tvID, seasonNumber: seasonNumber, episodeNumber: episodeNumber)
                    ) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
        .task { await loadEpisode() }
    }

    private func loadEpisode() async {
        isLoading = true
        error = nil
        do {
            let result = try await TMDBClient.shared.episodeDetail(tvID: tvID, seasonNumber: seasonNumber, episodeNumber: episodeNumber)
            episode = result

            // Fetch birthdays for guest stars & crew in background
            let guestIDs = (result.guestStars ?? []).map(\.id)
            let crewIDs = (result.crew ?? []).map(\.id)
            let allIDs = Array(Set(guestIDs + crewIDs))
            if !allIDs.isEmpty {
                let fetched = await TMDBClient.shared.fetchBirthdays(for: allIDs)
                birthdays = fetched
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
