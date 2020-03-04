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
        .package(url: "https://github.com/aliyun/tea-swift.git", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "TeaFileForm",
            dependencies: ["Tea"]),
        .testTarget(
            name: "TeaFileFormTests",
            dependencies: ["TeaFileForm", "Tea"]),
    ]
)
