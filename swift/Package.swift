// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TeaFileForm",
    platforms: [.macOS(.v10_15),
                .iOS(.v13),
                .tvOS(.v13),
                .watchOS(.v6)],
    products: [
        .library(
            name: "TeaFileForm",
            targets: ["TeaFileForm"])
    ],
    dependencies: [
        .package(url: "https://github.com/aliyun/tea-swift.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "TeaFileForm",
            dependencies: [
                .product(name: "Tea", package: "tea-swift")
            ]),
        .testTarget(
            name: "TeaFileFormTests",
            dependencies: [
                "TeaFileForm",
                .product(name: "Tea", package: "tea-swift")
            ]),
    ],
    swiftLanguageVersions: [.v5]
)
