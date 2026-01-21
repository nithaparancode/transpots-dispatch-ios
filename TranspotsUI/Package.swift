// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TranspotsUI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "TranspotsUI",
            targets: ["TranspotsUI"]),
    ],
    targets: [
        .target(
            name: "TranspotsUI",
            dependencies: []),
    ]
)
