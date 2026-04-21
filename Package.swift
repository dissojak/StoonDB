// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ServerSQLPanel",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ServerSQLPanel",
            targets: ["ServerSQLPanel"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ServerSQLPanel",
            path: "Sources"
        )
    ]
)
