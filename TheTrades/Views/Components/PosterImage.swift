import SwiftUI
import NukeUI

struct PosterImage: View {
    let url: URL?
    var width: CGFloat = 100
    var height: CGFloat = 150
    var placeholderSymbol: String = "film"

    var body: some View {
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
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
