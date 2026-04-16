// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SteinerCircleModel",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "SteinerCircleModel",
            targets: ["SteinerCircleModel"]),
    ],
    dependencies: [
        .package(url: "https://github.com/dndydon/PrimeFactorization.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "SteinerCircleModel",
            dependencies: ["PrimeFactorization"]),
        .testTarget(
            name: "SteinerCircleModelTests",
            dependencies: ["SteinerCircleModel"]),
    ]
)
