import SwiftUI

/// Small capsule badge identifying a result's media type (Movie / TV / Person).
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
