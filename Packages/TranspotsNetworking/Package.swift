// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "TranspotsNetworking",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "TranspotsNetworking",
            targets: ["TranspotsNetworking"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
    ],
    targets: [
        .target(
            name: "TranspotsNetworking",
            dependencies: ["Alamofire"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)
