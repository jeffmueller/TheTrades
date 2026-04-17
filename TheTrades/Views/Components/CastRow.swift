import SwiftUI
import NukeUI

struct CastRow: View {
    let id: Int
    let name: String
    let role: String?
    let profilePath: String?
    var ageAtRelease: Int? = nil

    var body: some View {
        NavigationLink(value: AppDestination.person(id: id)) {
            HStack(spacing: 14) {
                PosterImage(
                    url: ImageURLBuilder.profileURL(path: profilePath, size: .w185),
                    width: 40,
                    height: 60
                )
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(name)
                            .font(.body.weight(.medium))
                        if let ageAtRelease {
                            Text("\(ageAtRelease)")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 1)
                                .background(.fill, in: Capsule())
                        }
                    }
                    if let role, !role.isEmpty {
                        Text(role)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 2)
            .contentShape(Rectangle())
        }
    }
}
