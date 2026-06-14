import SwiftUI
import NukeUI
import UIKit

struct PersonDetailView: View {
    let personID: Int

    @Environment(LibraryStore.self) private var library
    @State private var person: Person?
    @State private var isLoading = true
    @State private var error: String?
    @State private var showFullBio = false

    var body: some View {
        LoadingStateView(isLoading: isLoading, error: error, retry: loadPerson) {
            if let person {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection(person)
                        bioSection(person)
                        filmographySection(person)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle(person?.name ?? "Person")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let person {
                ToolbarItem(placement: .topBarTrailing) {
                    BookmarkButton(item: .person(id: person.id, name: person.name, department: person.knownForDepartment, profilePath: person.profilePath))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: TMDBURLBuilder.person(id: personID)) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
        .task { await loadPerson() }
    }

    @ViewBuilder
    private func headerSection(_ person: Person) -> some View {
        HStack(alignment: .top, spacing: 16) {
            PosterImage(
                url: ImageURLBuilder.profileURL(path: person.profilePath, size: .w185),
                width: 120,
                height: 180,
                placeholderSymbol: "person.fill"
            )
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)

            VStack(alignment: .leading, spacing: 8) {
                Text(person.name)
                    .font(.title2.bold())
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = person.name
                        } label: {
                            Label("Copy Name", systemImage: "doc.on.doc")
                        }
                    }

                if let age = person.age {
                    if person.isDeceased {
                        Text("Died at age \(age)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Age \(age)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if let birthPlace = person.placeOfBirth {
                    Text(birthPlace)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if let department = person.knownForDepartment {
                    Text(department)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.fill, in: Capsule())
                }
            }
        }
    }

    @ViewBuilder
    private func bioSection(_ person: Person) -> some View {
        if let bio = person.biography, !bio.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text("Biography")
                    .font(.headline)
                Text(bio)
                    .font(.body)
                    .lineSpacing(2)
                    .lineLimit(showFullBio ? nil : 6)
                if bio.count > 300 {
                    Button(showFullBio ? "Show less" : "Read more") {
                        withAnimation(.easeInOut(duration: 0.25)) { showFullBio.toggle() }
                    }
                    .font(.subheadline.weight(.medium))
                }
            }
        }
    }

    @ViewBuilder
    private func filmographySection(_ person: Person) -> some View {
        if let movieCredits = person.movieCredits, !movieCredits.cast.isEmpty {
            DetailSection(title: "Movies") {
                ForEach(sortedMovieCredits(movieCredits.cast)) { credit in
                    NavigationLink(value: AppDestination.movie(id: credit.id)) {
                        MediaRow(
                            title: credit.displayTitle,
                            year: credit.year,
                            role: credit.character,
                            posterPath: credit.posterPath,
                            ageAtRelease: person.ageAtRelease(date: credit.displayDate)
                        )
                    }
                }
            }
        }

        if let tvCredits = person.tvCredits, !tvCredits.cast.isEmpty {
            DetailSection(title: "TV Shows") {
                ForEach(sortedTVCredits(tvCredits.cast)) { credit in
                    NavigationLink(value: AppDestination.tvShow(id: credit.id)) {
                        MediaRow(
                            title: credit.displayTitle,
                            year: credit.year,
                            role: credit.character,
                            posterPath: credit.posterPath,
                            ageAtRelease: person.ageAtRelease(date: credit.displayDate)
                        )
                    }
                }
            }
        }
    }

    private func sortedMovieCredits(_ credits: [PersonCastCredit]) -> [PersonCastCredit] {
        credits.sorted { a, b in
            let dateA = a.releaseDate ?? ""
            let dateB = b.releaseDate ?? ""
            return dateA > dateB
        }
    }

    private func sortedTVCredits(_ credits: [PersonCastCredit]) -> [PersonCastCredit] {
        var seen = Set<Int>()
        return credits.filter { seen.insert($0.id).inserted }
            .sorted { a, b in
                let dateA = a.firstAirDate ?? ""
                let dateB = b.firstAirDate ?? ""
                return dateA > dateB
            }
    }

    private func loadPerson() async {
        isLoading = true
        error = nil
        do {
            let result = try await TMDBClient.shared.personDetail(id: personID)
            person = result
            library.addRecentlyViewed(
                .person(id: result.id, name: result.name, department: result.knownForDepartment, profilePath: result.profilePath)
            )
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
