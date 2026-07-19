import SwiftUI

struct DiscoverView: View {
    @Environment(AppState.self) private var appState
    @Environment(LibraryStore.self) private var library
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

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
                searchResultsContent
            } else if appState.searchText.isEmpty {
                homeView
            } else {
                ContentUnavailableView.search(text: appState.searchText)
            }
        }
        .navigationTitle("Discover")
        .searchable(text: $appState.searchText, prompt: "Movies, TV shows, people...")
        .searchScopes($appState.searchFilter, activation: .onSearchPresentation) {
            ForEach(SearchFilter.allCases) { filter in
                Text(filter.title).tag(filter)
            }
        }
        .task(id: appState.searchText) {
            guard !appState.searchText.isEmpty else {
                appState.clearSearch()
                return
            }
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            await appState.search()
        }
    }

    // MARK: - Home (no active search)

    private var homeView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                discoverContent

                if !library.recentlyViewed.isEmpty {
                    PosterCarousel(
                        title: "Recently Viewed",
                        cards: library.recentlyViewed.prefix(15).map { PosterCardModel($0) }
                    )
                }

                if !appState.recentSearches.isEmpty {
                    recentSearchesSection
                }
            }
            .padding(.vertical, 16)
        }
        .refreshable { await appState.loadDiscover() }
        .task { await appState.loadDiscoverIfNeeded() }
    }

    @ViewBuilder
    private var discoverContent: some View {
        if appState.discoverSections.isEmpty {
            if appState.isLoadingDiscover {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 80)
            } else if let error = appState.discoverError {
                ContentUnavailableView {
                    Label("Couldn't Load Discover", systemImage: "wifi.slash")
                } description: {
                    Text(error)
                } actions: {
                    Button("Retry") {
                        Task { await appState.loadDiscover() }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top, 40)
            }
        } else {
            ForEach(appState.discoverSections) { section in
                PosterCarousel(title: section.title, cards: section.items.map { PosterCardModel($0) })
            }
        }
    }

    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Searches")
                    .font(.title3.bold())
                Spacer()
                Button("Clear") { appState.clearRecentSearches() }
                    .font(.subheadline)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 0) {
                ForEach(appState.recentSearches.prefix(10), id: \.self) { query in
                    HStack(spacing: 12) {
                        Button {
                            appState.searchText = query
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.secondary)
                                    .font(.footnote)
                                Text(query)
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Button {
                            appState.removeRecentSearch(query)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.tertiary)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Remove \(query)")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                    if query != appState.recentSearches.prefix(10).last {
                        Divider().padding(.leading, 50)
                    }
                }
            }
        }
    }

    // MARK: - Search Results (filtered + paginated)

    /// Rows in compact width; a poster grid once there's room for columns.
    @ViewBuilder
    private var searchResultsContent: some View {
        if appState.filteredSearchResults.isEmpty {
            ContentUnavailableView(
                "No \(appState.searchFilter.title)",
                systemImage: "magnifyingglass",
                description: Text("No results of this type. Try another filter.")
            )
        } else if horizontalSizeClass == .regular {
            searchResultsGrid
        } else {
            searchResultsList
        }
    }

    private var searchResultsGrid: some View {
        ScrollView {
            PosterGrid(
                cards: appState.filteredSearchResults.map { PosterCardModel($0) },
                onCardAppear: { loadMoreIfLast(id: $0.id) }
            )
            .padding(.vertical, 20)

            if appState.isLoadingMore {
                ProgressView()
                    .padding(.bottom, 24)
            }
        }
    }

    private var searchResultsList: some View {
        List {
            ForEach(appState.filteredSearchResults) { result in
                NavigationLink(value: result.appDestination) {
                    UnifiedSearchRow(result: result)
                }
                .onAppear { loadMoreIfLast(id: result.id) }
            }

            if appState.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.insetGrouped)
    }

    /// Pages in the next batch once the last row/cell comes on screen.
    private func loadMoreIfLast(id: String) {
        guard id == appState.filteredSearchResults.last?.id else { return }
        Task { await appState.loadMoreSearchResults() }
    }
}

// MARK: - Unified Search Row

private struct UnifiedSearchRow: View {
    let result: SearchResult

    private var subtitle: String? {
        switch result {
        case .movie(let m): return m.year
        case .tvShow(let t): return t.year
        case .person(let p): return p.knownForDepartment
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            PosterImage(
                url: result.isPerson
                    ? ImageURLBuilder.profileURL(path: result.imagePath, size: .w185)
                    : ImageURLBuilder.posterURL(path: result.imagePath, size: .w154),
                width: 48,
                height: 72,
                placeholderSymbol: result.isPerson ? "person.fill" : "film"
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(result.displayTitle)
                    .font(.body.weight(.medium))
                    .lineLimit(2)

                HStack(spacing: 6) {
                    TypeBadge(label: result.typeLabel, icon: typeIcon)

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(result.displayTitle), \(result.typeLabel)\(subtitle.map { ", \($0)" } ?? "")")
    }

    private var typeIcon: String {
        switch result {
        case .movie: return "film"
        case .tvShow: return "tv"
        case .person: return "person"
        }
    }
}
