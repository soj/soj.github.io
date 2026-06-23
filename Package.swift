// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SergeyMingalev",
    platforms: [.macOS(.v12)],
    products: [
        .executable(
            name: "SergeyMingalev",
            targets: ["SergeyMingalev"]
        )
    ],
    dependencies: [
        .package(name: "Publish", url: "https://github.com/johnsundell/publish.git", from: "0.8.0"),
        .package(url: "https://github.com/JohnSundell/SplashPublishPlugin", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "SergeyMingalev",
            dependencies: ["Publish", "SplashPublishPlugin"]
        )
    ]
)