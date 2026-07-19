import SwiftUI

/// The regular-width shell: the three sections live in a sidebar instead of a tab
/// bar, and the selected section's `NavigationStack` fills the detail column.
struct RootSplitView: View {
    @Environment(AppState.self) private var appState
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    /// The detail column's back stack, owned here rather than read from `AppState`.
    /// The column reuses a single `NavigationStack`, and a stack handed a different
    /// path binding writes its own state back into it — pointing it at the per-tab
    /// paths corrupts whichever section you switch to. One stack, one path, cleared
    /// on section change: switching sections lands you on that section's root.
    ///
    /// (Keeping a stack per section instead needs all three alive at once, i.e. a
    /// hidden-tab-bar `TabView` in the detail column. That costs the column its
    /// navigation bar — including Discover's search field — so it isn't worth it.)
    @State private var detailPath = NavigationPath()

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(AppTab.allCases, id: \.self, selection: sidebarSelection) { tab in
                Label(tab.title, systemImage: tab.systemImage)
            }
            .navigationTitle("TheTrades")
        } detail: {
            TabNavigationStack(tab: appState.selectedTab, path: $detailPath)
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: appState.selectedTab) {
            // The new section's root has no use for the old section's destinations.
            detailPath = NavigationPath()
        }
    }

    /// `List` selection is optional because a tap can deselect, but the app always
    /// has a section on screen — a nil selection just keeps the current one.
    private var sidebarSelection: Binding<AppTab?> {
        Binding(
            get: { appState.selectedTab },
            set: { if let tab = $0 { appState.selectedTab = tab } }
        )
    }
}
