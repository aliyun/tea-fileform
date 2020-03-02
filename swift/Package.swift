// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TeaFileForm",
    products: [
        .library(
            name: "TeaFileForm",
            targets: ["TeaFileForm"])
    ],
    dependencies: [
        .package(url: "https://github.com/aliyun/tea-swift.git", from: "0.2.0"),
        .package(url: "https://github.com/yannickl/AwaitKit.git", from: "5.2.0")
    ],
    targets: [
        .target(
            name: "TeaFileForm",
            dependencies: ["Tea", "AwaitKit"]),
        .testTarget(
            name: "TeaFileFormTests",
            dependencies: ["TeaFileForm", "Tea", "AwaitKit"]),
    ]
)
