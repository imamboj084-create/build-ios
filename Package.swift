// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AnichinApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AnichinApp",
            targets: ["AnichinApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0")
    ],
    targets: [
        .target(
            name: "AnichinApp",
            dependencies: ["SwiftSoup"])
    ]
)
