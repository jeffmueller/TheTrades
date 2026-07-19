import SwiftUI
import NukeUI

struct PosterImage: View {
    /// Poster height as a multiple of width (the standard 2:3 poster ratio).
    static let posterAspectHeight: CGFloat = 1.5

    let url: URL?
    /// A `nil` width lets the poster fill the width it's offered and take its
    /// height from the poster ratio — used by the cells in `PosterGrid`.
    var width: CGFloat? = 100
    var height: CGFloat? = 150
    var placeholderSymbol: String = "film"

    var body: some View {
        Group {
            if width == nil {
                image.aspectRatio(1 / Self.posterAspectHeight, contentMode: .fit)
            } else {
                image.frame(width: width, height: height)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var image: some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if state.isLoading {
                Rectangle()
                    .fill(.quaternary)
                    .overlay {
                        ProgressView()
                            .controlSize(.small)
                    }
            } else {
                Rectangle()
                    .fill(.quaternary)
                    .overlay {
                        Image(systemName: placeholderSymbol)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
            }
        }
    }
}
