import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(LibraryStore.self) private var library

    var body: some View {
        @Bindable var appState = appState

        Form {
            Section("Appearance") {
                Picker("Theme", selection: $appState.appearance) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Text(appearance.title).tag(appearance)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Toggle("Spoiler Mode", isOn: $appState.spoilerMode)
            } header: {
                Text("Viewing")
            } footer: {
                Text("Blurs episode titles, stills, and overviews until you tap to reveal them.")
            }

            Section("Data") {
                Button("Clear Recently Viewed", role: .destructive) {
                    library.clearRecentlyViewed()
                }
                .disabled(library.recentlyViewed.isEmpty)

                Button("Clear Saved", role: .destructive) {
                    library.clearWatchlist()
                }
                .disabled(library.watchlist.isEmpty)
            }

            Section {
                Link(destination: URL(string: "https://www.themoviedb.org")!) {
                    Label("The Movie Database", systemImage: "link")
                }
            } header: {
                Text("About")
            } footer: {
                Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
            }
        }
        .navigationTitle("Settings")
    }
}
