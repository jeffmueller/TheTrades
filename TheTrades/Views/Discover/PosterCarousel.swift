import SwiftUI

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
