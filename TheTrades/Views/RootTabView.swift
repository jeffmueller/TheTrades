import SwiftUI

/// Root of the app: a three-tab shell (Discover · Saved · Settings), each tab
/// owning its own `NavigationStack` and back stack via paths held in `AppState`.
struct RootTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            NavigationStack(path: $appState.discoverPath) {
                DiscoverView()
                    .withAppDestinations()
            }
            .tabItem { Label(AppTab.discover.title, systemImage: AppTab.discover.systemImage) }
            .tag(AppTab.discover)

            NavigationStack(path: $appState.savedPath) {
                WatchlistView()
                    .withAppDestinations()
            }
            .tabItem { Label(AppTab.saved.title, systemImage: AppTab.saved.systemImage) }
            .tag(AppTab.saved)

            NavigationStack(path: $appState.settingsPath) {
                SettingsView()
                    .withAppDestinations()
            }
            .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.systemImage) }
            .tag(AppTab.settings)
        }
        .preferredColorScheme(appState.appearance.colorScheme)
    }
}
