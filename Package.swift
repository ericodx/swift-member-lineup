// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SwiftMemberLineUp",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1),
    ],
    products: [
        .plugin(name: "SwiftMemberLineUpPlugin", targets: ["SwiftMemberLineUpPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.7.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "6.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "swift-member-lineup",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "SwiftMemberLineUpTests",
            dependencies: ["swift-member-lineup"],
            resources: [
                .copy("Snapshots/Fixtures"),
                .copy("Snapshots/Expected"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .plugin(
            name: "SwiftMemberLineUpPlugin",
            capability: .buildTool(),
            dependencies: ["swift-member-lineup"]
        ),
    ]
)
