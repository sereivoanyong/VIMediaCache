// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "VIMediaCache",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "VIMediaCache", targets: ["VIMediaCache"])
    ],
    targets: [
        .target(name: "VIMediaCache", publicHeadersPath: "include", cSettings: [.headerSearchPath("./**")]),
    ]
)
