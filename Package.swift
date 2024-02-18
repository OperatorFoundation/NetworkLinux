// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkLinux",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "NetworkLinux",
            targets: ["NetworkLinux"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OperatorFoundation/BlueSocket", from: "1.1.1"),
        .package(url: "https://github.com/OperatorFoundation/SwiftHexTools", from: "1.2.6"),
    ],
    targets: [
        .target(
            name: "NetworkLinux",
            dependencies: [
                "SwiftHexTools",
                .product(name: "Socket", package: "BlueSocket")
            ]),
        .testTarget(
            name: "NetworkLinuxTests",
            dependencies: ["NetworkLinux"]),
    ],
    swiftLanguageVersions: [.v5]
)
