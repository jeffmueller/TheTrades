import SwiftUI

/// The compact-width shell: a three-tab bar (Discover · Saved · Settings), each
/// tab owning its own `NavigationStack` and back stack via paths held in `AppState`.
struct RootTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                TabNavigationStack(tab: tab, path: appState.pathBinding(for: tab))
                    .tabItem { Label(tab.title, systemImage: tab.systemImage) }
                    .tag(tab)
            }
        }
    }
}
