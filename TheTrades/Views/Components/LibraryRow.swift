import SwiftUI

/// A poster + title + type badge row for a `LibraryItem`, shared by the
/// Recently Viewed section and the Saved watchlist.
struct LibraryRow: View {
    let item: LibraryItem
    var posterWidth: CGFloat = 40
    var posterHeight: CGFloat = 60

    var body: some View {
        HStack(spacing: 14) {
            PosterImage(
                url: item.destination.isPerson
                    ? ImageURLBuilder.profileURL(path: item.imagePath, size: .w185)
                    : ImageURLBuilder.posterURL(path: item.imagePath, size: .w154),
                width: posterWidth,
                height: posterHeight,
                placeholderSymbol: item.destination.isPerson ? "person.fill" : "film"
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body.weight(.medium))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    TypeBadge(label: item.destination.typeLabel, icon: item.destination.typeIcon)

                    if let subtitle = item.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        var parts = [item.title, item.destination.typeLabel]
        if let subtitle = item.subtitle, !subtitle.isEmpty { parts.append(subtitle) }
        return parts.joined(separator: ", ")
    }
}
