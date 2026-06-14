import Foundation

enum AppTab: Hashable, CaseIterable {
    case discover
    case saved
    case settings

    var title: String {
        switch self {
        case .discover: return "Discover"
        case .saved: return "Saved"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .discover: return "film.stack"
        case .saved: return "bookmark"
        case .settings: return "gearshape"
        }
    }
}
