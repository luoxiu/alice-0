// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Alice",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v10),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(name: "Future", targets: ["Future"]),
        .library(name: "Alice", targets: ["Alice"]),
        .executable(name: "ping", targets: ["ping"])
    ],
    targets: [
        .target(name: "Future"),
        .target(name: "Alice", dependencies: ["Future"]),
        .testTarget(name: "AliceTests", dependencies: ["Alice"]),
        .target(name: "ping", dependencies: ["Alice"])
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
