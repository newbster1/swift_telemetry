// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TelemetryKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "TelemetryKit",
            targets: ["TelemetryKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.25.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "TelemetryKit",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources/TelemetryKit"
        ),
        .testTarget(
            name: "TelemetryKitTests",
            dependencies: ["TelemetryKit"],
            path: "Tests/TelemetryKitTests"
        ),
    ]
)