// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sherpa",
    platforms: [
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "Sherpa",
            targets: ["Sherpa"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Sherpa",
            dependencies: [],
            path: "Sources/Sherpa",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SherpaTests",
            dependencies: ["Sherpa"],
            path: "Tests/SherpaTests"
        ),
    ]
)
