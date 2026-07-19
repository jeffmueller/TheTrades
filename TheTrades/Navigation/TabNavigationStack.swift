import SwiftUI

/// One section's `NavigationStack`: its root view plus the shared destination map.
/// The tab bar gives each tab a long-lived stack driven by that tab's stored path;
/// the sidebar gives its single detail column one stack driven by the column's own.
struct TabNavigationStack: View {
    let tab: AppTab
    @Binding var path: NavigationPath

    var body: some View {
        NavigationStack(path: $path) {
            root
                .withAppDestinations()
        }
    }

    @ViewBuilder
    private var root: some View {
        switch tab {
        case .discover:
            DiscoverView()
        case .saved:
            WatchlistView()
        case .settings:
            SettingsView()
        }
    }
}
