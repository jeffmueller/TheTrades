import SwiftUI
import NukeUI

/// Horizontal row of trailer thumbnails. Tapping a card opens the trailer on
/// YouTube via the system `openURL` (no embedded player).
struct TrailerCarousel: View {
    let videos: [Video]
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(videos) { video in
                    Button {
                        if let url = video.youtubeURL {
                            Haptics.selection()
                            openURL(url)
                        }
                    } label: {
                        TrailerThumbnail(video: video)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Play trailer: \(video.name)")
                }
            }
        }
    }
}

private struct TrailerThumbnail: View {
    let video: Video

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                LazyImage(url: video.thumbnailURL) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle().fill(.quaternary)
                    }
                }
                .frame(width: 240, height: 135)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(.white, .black.opacity(0.55))
                    .shadow(color: .black.opacity(0.3), radius: 4)
            }

            Text(video.name)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 240, alignment: .leading)
        }
    }
}
