// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkLinux",
    platforms: [.macOS(.v11)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "NetworkLinux",
            targets: ["NetworkLinux"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Socket", url: "https://github.com/OperatorFoundation/BlueSocket", from: "1.1.0"),
        .package(url: "https://github.com/OperatorFoundation/SwiftHexTools", from: "1.2.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "NetworkLinux",
            dependencies: ["Socket", "SwiftHexTools"]),
        .testTarget(
            name: "NetworkLinuxTests",
            dependencies: ["NetworkLinux"]),
    ],
    swiftLanguageVersions: [.v5]
)
