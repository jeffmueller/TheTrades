import SwiftUI

struct MediaRow: View {
    let title: String
    let year: String?
    let role: String?
    let posterPath: String?
    let ageAtRelease: Int?

    var body: some View {
        HStack(spacing: 14) {
            PosterImage(
                url: ImageURLBuilder.posterURL(path: posterPath, size: .w154),
                width: 48,
                height: 72
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.medium))
                    .lineLimit(2)
                HStack(spacing: 6) {
                    if let year {
                        Text(year)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    if let ageAtRelease {
                        Text("Age \(ageAtRelease)")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(.fill, in: Capsule())
                    }
                }
                if let role, !role.isEmpty {
                    Text(role)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        var parts = [title]
        if let year { parts.append(year) }
        if let role, !role.isEmpty { parts.append(role) }
        if let ageAtRelease { parts.append("aged \(ageAtRelease) at release") }
        return parts.joined(separator: ", ")
    }
}
