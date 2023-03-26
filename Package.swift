// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Keyboard",
    products: [
        .library(name: "Keyboard",
                 targets: ["Keyboard"]),
        ],
    targets: [
        .target(
            name: "Keyboard"
        ),
    ],
    swiftLanguageVersions: [4.2, 5.0]
)
