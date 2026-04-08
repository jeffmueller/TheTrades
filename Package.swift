// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TheTrades",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "TheTrades", targets: ["TheTrades"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke.git", from: "12.8.0"),
    ],
    targets: [
        .target(
            name: "TheTrades",
            dependencies: [
                .product(name: "NukeUI", package: "Nuke"),
            ],
            path: "TheTrades"
        ),
        .testTarget(
            name: "TheTradesTests",
            dependencies: ["TheTrades"],
            path: "TheTradesTests"
        ),
    ]
)
