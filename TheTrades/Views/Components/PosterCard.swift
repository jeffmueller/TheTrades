import SwiftUI

/// A normalized view model for a poster card, so the carousels and grids can render
/// search results and library items through one code path.
struct PosterCardModel: Identifiable, Hashable {
    let id: String
    let title: String
    let typeLabel: String
    let imagePath: String?
    let isPerson: Bool
    let destination: AppDestination

    init(_ result: SearchResult) {
        id = result.id
        title = result.displayTitle
        typeLabel = result.typeLabel
        imagePath = result.imagePath
        isPerson = result.isPerson
        destination = result.appDestination
    }

    init(_ item: LibraryItem) {
        id = item.id
        title = item.title
        typeLabel = item.destination.typeLabel
        imagePath = item.imagePath
        isPerson = item.destination.isPerson
        destination = item.destination.appDestination
    }
}

/// A tappable poster with its title underneath: fixed-width inside the Discover
/// carousels, container-width (`width: nil`) inside `PosterGrid`.
struct PosterCard: View {
    let card: PosterCardModel
    var width: CGFloat? = 110

    private var imageURL: URL? {
        card.isPerson
            ? ImageURLBuilder.profileURL(path: card.imagePath, size: .w185)
            : ImageURLBuilder.posterURL(path: card.imagePath, size: .w342)
    }

    var body: some View {
        NavigationLink(value: card.destination) {
            VStack(alignment: .leading, spacing: 6) {
                PosterImage(
                    url: imageURL,
                    width: width,
                    height: width.map { $0 * PosterImage.posterAspectHeight },
                    placeholderSymbol: card.isPerson ? "person.fill" : "film"
                )
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

                Text(card.title)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(width: width, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.title), \(card.typeLabel)")
    }
}
