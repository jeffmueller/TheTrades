import SwiftUI

@main
struct TheTradesApp: App {
    @State private var appState = AppState()
    @State private var library = LibraryStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .tint(.accentColor)
                .environment(appState)
                .environment(library)
        }
    }
}
