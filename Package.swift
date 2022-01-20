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
        .package(name: "Socket", url: "https://github.com/OperatorFoundation/BlueSocket.git", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/SwiftHexTools.git", from: "1.2.2"),
    ],
    targets: [
        .target(
            name: "NetworkLinux",
            dependencies: ["Socket", "SwiftHexTools"]),
        .testTarget(
            name: "NetworkLinuxTests",
            dependencies: ["NetworkLinux"]),
    ],
    swiftLanguageVersions: [.v5]
)
