import SwiftUI

struct SearchView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        Group {
            if appState.isSearching {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = appState.searchError {
                ContentUnavailableView {
                    Label("Search Failed", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error)
                } actions: {
                    Button("Retry") {
                        Task { await appState.search() }
                    }
                    .buttonStyle(.bordered)
                }
            } else if !appState.searchResults.isEmpty {
                searchResultsList
            } else if appState.searchText.isEmpty {
                homeView
            } else {
                ContentUnavailableView.search(text: appState.searchText)
            }
        }
        .navigationTitle("TheTrades")
        .searchable(text: $appState.searchText, prompt: "Movies, TV shows, people...")
        .task(id: appState.searchText) {
            guard !appState.searchText.isEmpty else {
                appState.clearSearch()
                return
            }
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await appState.search()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.spoilerMode.toggle()
                } label: {
                    Image(systemName: appState.spoilerMode ? "eye.slash" : "eye")
                        .symbolRenderingMode(.hierarchical)
                }
                .accessibilityLabel(appState.spoilerMode ? "Disable spoiler mode" : "Enable spoiler mode")
            }
        }
    }

    // MARK: - Home (no active search)

    private var homeView: some View {
        List {
            if !appState.recentlyViewed.isEmpty {
                Section {
                    ForEach(appState.recentlyViewed.prefix(10)) { item in
                        NavigationLink(value: item.destination.appDestination) {
                            RecentlyViewedRow(item: item)
                        }
                    }
                } header: {
                    HStack {
                        Text("Recently Viewed")
                        Spacer()
                        Button("Clear") {
                            appState.clearRecentlyViewed()
                        }
                        .font(.caption)
                        .textCase(nil)
                    }
                }
            }

            if !appState.recentSearches.isEmpty {
                Section {
                    ForEach(appState.recentSearches, id: \.self) { query in
                        Button {
                            appState.searchText = query
                        } label: {
                            Label {
                                Text(query)
                                    .foregroundStyle(.primary)
                            } icon: {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.secondary)
                                    .font(.footnote)
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                appState.removeRecentSearch(query)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                    }
                } header: {
                    HStack {
                        Text("Recent Searches")
                        Spacer()
                        Button("Clear") {
                            appState.clearRecentSearches()
                        }
                        .font(.caption)
                        .textCase(nil)
                    }
                }
            }

            if appState.recentlyViewed.isEmpty && appState.recentSearches.isEmpty {
                ContentUnavailableView(
                    "Search Movies & TV",
                    systemImage: "magnifyingglass",
                    description: Text("Search for movies, TV shows, and actors")
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Unified Search Results

    private var searchResultsList: some View {
        List {
            ForEach(appState.searchResults) { result in
                switch result {
                case .movie(let movie):
                    NavigationLink(value: AppDestination.movie(id: movie.id)) {
                        UnifiedSearchRow(
                            title: movie.title,
                            subtitle: movie.year,
                            typeLabel: "Movie",
                            typeIcon: "film",
                            imagePath: movie.posterPath,
                            imageIsProfile: false
                        )
                    }
                case .tvShow(let tvShow):
                    NavigationLink(value: AppDestination.tvShow(id: tvShow.id)) {
                        UnifiedSearchRow(
                            title: tvShow.name,
                            subtitle: tvShow.year,
                            typeLabel: "TV",
                            typeIcon: "tv",
                            imagePath: tvShow.posterPath,
                            imageIsProfile: false
                        )
                    }
                case .person(let person):
                    NavigationLink(value: AppDestination.person(id: person.id)) {
                        UnifiedSearchRow(
                            title: person.name,
                            subtitle: person.knownForDepartment,
                            typeLabel: "Person",
                            typeIcon: "person",
                            imagePath: person.profilePath,
                            imageIsProfile: true
                        )
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Unified Search Row

private struct UnifiedSearchRow: View {
    let title: String
    let subtitle: String?
    let typeLabel: String
    let typeIcon: String
    let imagePath: String?
    let imageIsProfile: Bool

    var body: some View {
        HStack(spacing: 14) {
            PosterImage(
                url: imageIsProfile
                    ? ImageURLBuilder.profileURL(path: imagePath, size: .w185)
                    : ImageURLBuilder.posterURL(path: imagePath, size: .w154),
                width: 48,
                height: 72
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.medium))
                    .lineLimit(2)

                HStack(spacing: 6) {
                    TypeBadge(label: typeLabel, icon: typeIcon)

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Type Badge

struct TypeBadge: View {
    let label: String
    let icon: String

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2)
            Text(label)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 7)
        .padding(.vertical, 2)
        .background(.fill, in: Capsule())
    }
}

// MARK: - Recently Viewed Row

private struct RecentlyViewedRow: View {
    let item: RecentlyViewedItem

    var body: some View {
        HStack(spacing: 14) {
            PosterImage(
                url: item.destination.typeIcon == "person"
                    ? ImageURLBuilder.profileURL(path: item.imagePath, size: .w185)
                    : ImageURLBuilder.posterURL(path: item.imagePath, size: .w154),
                width: 40,
                height: 60
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body.weight(.medium))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    TypeBadge(label: item.destination.typeLabel, icon: item.destination.typeIcon)

                    if let subtitle = item.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }
}
