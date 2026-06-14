import SwiftUI

/// A normalized view model for a poster card, so the carousel can render
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

/// A titled, horizontally-scrolling row of poster cards.
struct PosterCarousel: View {
    let title: String
    let cards: [PosterCardModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3.bold())
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(cards) { card in
                        PosterCard(card: card)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

private struct PosterCard: View {
    let card: PosterCardModel

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
                    width: 110,
                    height: 165,
                    placeholderSymbol: card.isPerson ? "person.fill" : "film"
                )
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

                Text(card.title)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(width: 110, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.title), \(card.typeLabel)")
    }
}
