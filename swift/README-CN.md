[English](README.md) | 简体中文

![](https://aliyunsdk-pages.alicdn.com/icons/AlibabaCloud.svg)

## Aliyun Tea File Library for Swift

## 安装

### CocoaPods

[CocoaPods](https://cocoapods.org) 是 Cocoa 项目管理工具。请访问其官方网站获取关于 CocoaPods 的使用和安装说明。要使用 CocoaPods 将 `TeaFileForm` 集成到你的 Xcode 项目中，需要在 `Podfile` 中定义以下内容:

```ruby
pod 'TeaFileForm', '~> 0.1.0'
```

### Carthage

要使用 [Carthage](https://github.com/Carthage/Carthage) 将 Tea 集成到你的 Xcode 项目中，需要在 `Cartfile` 中定义以下内容:

```ogdl
github "alibabacloud-sdk-swift/tea-fileform" "0.1.0"
```

### Swift 包管理工具

要使用 [Swift Package Manager](https://swift.org/package-manager/) 将 Tea 集成到你的 Xcode 项目中，请将 Tea 添加至你的 `Package.swift` 文件的 dependencies 数组内容中:

```swift
dependencies: [
    .package(url: "https://github.com/alibabacloud-sdk-swift/tea-fileform.git", from: "0.1.0")
]
```

另外，还需要在 `target` 的 `dependencies` 中添加 `"TeaFileForm"`，如下：

```swift
.target(
    name: "<your-project-name>",
    dependencies: [
        "TeaFileForm",
    ]),
```

## 问题

[提交 Issue](https://github.com/aliyun/tea-fileform/issues/new)，不符合指南的问题可能会立即关闭。

## 发行说明

每个版本的详细更改记录在[发行说明](./ChangeLog.txt)中。

## 相关

* [最新源码](https://github.com/aliyun/tea-fileform/tree/master/swift)

## 许可证

[Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Copyright (c) 2009-present, Alibaba Cloud All rights reserved.
