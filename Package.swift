// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "StoonDB",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "StoonDB",
            targets: ["StoonDB"]
        )
    ],
    targets: [
        .executableTarget(
            name: "StoonDB",
            path: "Sources"
        )
    ]
)
