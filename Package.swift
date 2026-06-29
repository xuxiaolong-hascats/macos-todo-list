// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MacOSTodoList",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MacOSTodoList", targets: ["MacOSTodoList"])
    ],
    targets: [
        .target(name: "MacOSTodoListCore"),
        .executableTarget(
            name: "MacOSTodoList",
            dependencies: ["MacOSTodoListCore"]
        ),
        .testTarget(
            name: "MacOSTodoListCoreTests",
            dependencies: ["MacOSTodoListCore"]
        )
    ]
)
