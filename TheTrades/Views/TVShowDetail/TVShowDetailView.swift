import SwiftUI
import NukeUI

struct TVShowDetailView: View {
    let tvShowID: Int

    @Environment(LibraryStore.self) private var library
    @State private var tvShow: TVShow?
    @State private var birthdays: [Int: String] = [:]
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        LoadingStateView(isLoading: isLoading, error: error, retry: loadTVShow) {
            if let tvShow {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection(tvShow)
                        detailContent(tvShow)
                    }
                }
            }
        }
        .navigationTitle(tvShow?.name ?? "TV Show")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let tvShow {
                ToolbarItem(placement: .topBarTrailing) {
                    BookmarkButton(item: .tvShow(id: tvShow.id, name: tvShow.name, yearRange: tvShow.yearRange, posterPath: tvShow.posterPath))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: TMDBURLBuilder.tvShow(id: tvShowID)) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
        .task { await loadTVShow() }
    }

    @ViewBuilder
    private func headerSection(_ tvShow: TVShow) -> some View {
        ZStack(alignment: .bottomLeading) {
            LazyImage(url: ImageURLBuilder.backdropURL(path: tvShow.backdropPath)) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle().fill(.quaternary)
                }
            }
            .frame(height: 240)
            .clipped()
            .overlay {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black.opacity(0.35), location: 0.55),
                        .init(color: .black.opacity(0.9), location: 1.0),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }

            HStack(alignment: .bottom, spacing: 16) {
                PosterImage(
                    url: ImageURLBuilder.posterURL(path: tvShow.posterPath, size: .w342),
                    width: 100,
                    height: 150
                )
                .shadow(color: .black.opacity(0.4), radius: 12, y: 4)

                VStack(alignment: .leading, spacing: 6) {
                    Text(tvShow.name)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    HStack(spacing: 10) {
                        if let yearRange = tvShow.yearRange {
                            Text(yearRange)
                        }
                        if let seasons = tvShow.numberOfSeasons {
                            Text("\(seasons) Season\(seasons == 1 ? "" : "s")")
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                }
                .padding(.bottom, 10)
                .shadow(color: .black.opacity(0.5), radius: 4, y: 1)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    private func detailContent(_ tvShow: TVShow) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            if let genres = tvShow.genres, !genres.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(genres) { genre in
                            Text(genre.name)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(.fill, in: Capsule())
                        }
                    }
                }
            }

            if let tagline = tvShow.tagline, !tagline.isEmpty {
                Text(tagline)
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.secondary)
            }

            if let overview = tvShow.overview, !overview.isEmpty {
                Text(overview)
                    .font(.body)
                    .lineSpacing(2)
            }

            let trailers = tvShow.videos?.trailers ?? []
            if !trailers.isEmpty {
                DetailSection(title: "Trailers") {
                    TrailerCarousel(videos: trailers)
                }
            }

            if let seasons = tvShow.seasons, !seasons.isEmpty {
                DetailSection(title: "Seasons") {
                    ForEach(seasons) { season in
                        NavigationLink(value: AppDestination.season(tvID: tvShowID, seasonNumber: season.seasonNumber)) {
                            HStack(spacing: 14) {
                                PosterImage(
                                    url: ImageURLBuilder.posterURL(path: season.posterPath, size: .w154),
                                    width: 48,
                                    height: 72
                                )
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(season.name ?? "Season \(season.seasonNumber)")
                                        .font(.body.weight(.medium))
                                    HStack(spacing: 8) {
                                        if let year = season.year {
                                            Text(year)
                                        }
                                        if let count = season.episodeCount {
                                            Text("\(count) episodes")
                                        }
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 2)
                            .contentShape(Rectangle())
                        }
                    }
                }
            }

            if let credits = tvShow.credits, !credits.cast.isEmpty {
                DetailSection(title: "Cast") {
                    ForEach(credits.cast.prefix(20)) { member in
                        CastRow(
                            id: member.id, name: member.name, role: member.character,
                            profilePath: member.profilePath,
                            ageAtRelease: AgeCalculator.age(birthday: birthdays[member.id], at: tvShow.firstAirDate)
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 40)
    }

    private func loadTVShow() async {
        isLoading = true
        error = nil
        do {
            let result = try await TMDBClient.shared.tvShowDetail(id: tvShowID)
            tvShow = result
            library.addRecentlyViewed(
                .tvShow(id: result.id, name: result.name, yearRange: result.yearRange, posterPath: result.posterPath)
            )

            // Fetch birthdays for cast in background
            if let credits = result.credits, !credits.cast.isEmpty {
                birthdays = await TMDBClient.shared.fetchBirthdays(for: credits.personIDs(includeCrew: false))
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
