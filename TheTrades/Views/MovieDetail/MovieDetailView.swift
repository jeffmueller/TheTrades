import SwiftUI
import NukeUI

struct MovieDetailView: View {
    let movieID: Int

    @Environment(LibraryStore.self) private var library
    @State private var movie: Movie?
    @State private var birthdays: [Int: String] = [:]
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        LoadingStateView(isLoading: isLoading, error: error, retry: loadMovie) {
            if let movie {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection(movie)
                        detailContent(movie)
                    }
                }
            }
        }
        .navigationTitle(movie?.title ?? "Movie")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let movie {
                ToolbarItem(placement: .topBarTrailing) {
                    BookmarkButton(item: .movie(id: movie.id, title: movie.title, year: movie.year, posterPath: movie.posterPath))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: TMDBURLBuilder.movie(id: movieID)) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
        .task { await loadMovie() }
    }

    @ViewBuilder
    private func headerSection(_ movie: Movie) -> some View {
        ZStack(alignment: .bottomLeading) {
            LazyImage(url: ImageURLBuilder.backdropURL(path: movie.backdropPath)) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
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
                    url: ImageURLBuilder.posterURL(path: movie.posterPath, size: .w342),
                    width: 100,
                    height: 150
                )
                .shadow(color: .black.opacity(0.4), radius: 12, y: 4)

                VStack(alignment: .leading, spacing: 6) {
                    Text(movie.title)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    HStack(spacing: 10) {
                        if let year = movie.year {
                            Text(year)
                        }
                        if let runtime = movie.formattedRuntime {
                            Text(runtime)
                        }
                        if let rating = movie.voteAverage, rating > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                Text(String(format: "%.1f", rating))
                            }
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
    private func detailContent(_ movie: Movie) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            if let genres = movie.genres, !genres.isEmpty {
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

            if let tagline = movie.tagline, !tagline.isEmpty {
                Text(tagline)
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.secondary)
            }

            if let overview = movie.overview, !overview.isEmpty {
                Text(overview)
                    .font(.body)
                    .lineSpacing(2)
            }

            let trailers = movie.videos?.trailers ?? []
            if !trailers.isEmpty {
                DetailSection(title: "Trailers") {
                    TrailerCarousel(videos: trailers)
                }
            }

            if let credits = movie.credits {
                let directors = credits.directors
                if !directors.isEmpty {
                    DetailSection(title: "Director\(directors.count > 1 ? "s" : "")") {
                        ForEach(directors) { member in
                            CastRow(
                                id: member.id, name: member.name, role: member.job,
                                profilePath: member.profilePath,
                                ageAtRelease: AgeCalculator.age(birthday: birthdays[member.id], at: movie.releaseDate)
                            )
                        }
                    }
                }

                if !credits.cast.isEmpty {
                    DetailSection(title: "Cast") {
                        ForEach(credits.cast.prefix(20)) { member in
                            CastRow(
                                id: member.id, name: member.name, role: member.character,
                                profilePath: member.profilePath,
                                ageAtRelease: AgeCalculator.age(birthday: birthdays[member.id], at: movie.releaseDate)
                            )
                        }
                    }
                }

                let keyCrew = credits.keyCrew
                if !keyCrew.isEmpty {
                    DetailSection(title: "Crew") {
                        ForEach(keyCrew) { member in
                            CastRow(
                                id: member.id, name: member.name, role: member.job,
                                profilePath: member.profilePath,
                                ageAtRelease: AgeCalculator.age(birthday: birthdays[member.id], at: movie.releaseDate)
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 40)
    }

    private func loadMovie() async {
        isLoading = true
        error = nil
        do {
            let result = try await TMDBClient.shared.movieDetail(id: movieID)
            movie = result
            library.addRecentlyViewed(
                .movie(id: result.id, title: result.title, year: result.year, posterPath: result.posterPath)
            )

            // Fetch birthdays for cast & crew in background
            if let credits = result.credits {
                birthdays = await TMDBClient.shared.fetchBirthdays(for: credits.personIDs())
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
