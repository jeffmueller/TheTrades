import SwiftUI

/// A multi-column grid of poster cards — the regular-width counterpart to the
/// full-width rows the same content uses in compact width.
struct PosterGrid: View {
    let cards: [PosterCardModel]
    var minCardWidth: CGFloat = 130
    /// Called as each card comes on screen, for pagination.
    var onCardAppear: ((PosterCardModel) -> Void)?
    /// When set, each card gets a destructive "Remove" context-menu action —
    /// the grid's stand-in for swipe-to-delete, which only lists offer.
    var onRemove: ((PosterCardModel) -> Void)?

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: minCardWidth), spacing: 20, alignment: .top)],
            alignment: .leading,
            spacing: 24
        ) {
            ForEach(cards) { card in
                cell(card)
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func cell(_ card: PosterCardModel) -> some View {
        let poster = PosterCard(card: card, width: nil)
            .onAppear { onCardAppear?(card) }

        if let onRemove {
            poster.contextMenu {
                Button(role: .destructive) {
                    onRemove(card)
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            }
        } else {
            poster
        }
    }
}
