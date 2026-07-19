import SwiftUI

/// Picks the shell that fits the current width: the tab bar in compact width
/// (iPhone, and iPad in a narrow Split View slot), the sidebar split in regular
/// width. Both shells read their back stacks from `AppState`, so a rotation or
/// resize that swaps shells preserves navigation history.
struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                RootSplitView()
            } else {
                RootTabView()
            }
        }
        .preferredColorScheme(appState.appearance.colorScheme)
    }
}
