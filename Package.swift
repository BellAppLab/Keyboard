// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Keyboard",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_13),
        .tvOS(.v13),
        .watchOS(.v5)
    ],
    products: [
        .library(
            name: "Keyboard",
            type: .static,
            targets: ["iOS Example"]),
    ],
    targets: [
        .target(
            name: "Keyboard"
        ),
        .testTarget(
            name: "iOS Tests",
            dependencies: ["Keyboard"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
