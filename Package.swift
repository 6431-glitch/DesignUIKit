// swift-tools-version: 5.9

/**
 *  ComponentSystem
 *  Copyright (c) Duke Nguyen 2022
 *  Licensed under the MIT license. See LICENSE file.
 */
import PackageDescription

let package = Package(
    name: "DesignUIKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DesignCore",
            targets: ["DesignCore"]
        ),
        .library(
            name: "DesignExts",
            targets: ["DesignExts"]
        ),
        .library(
            name: "DesignExternal",
            targets: ["DesignExternal"]
        ),
        .library(
            name: "DesignCombineUIKit",
            targets: ["DesignCombineUIKit"]
        ),
        .library(
            name: "DesignUIKit",
            targets: ["DesignUIKit"]
        ),
        .library(
            name: "DesignRxUIKit",
            targets: ["DesignRxUIKit"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/nvzqz/FileKit.git", .upToNextMajor(from: "6.1.0")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1")),
        .package(url: "https://github.com/kean/Nuke.git", .upToNextMajor(from: "12.4.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.5.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DesignCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Core",
            exclude: ["Archived/"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "DesignExts",
            dependencies: [
                .target(name: "DesignCore")
            ],
            path: "Sources/Exts",
            exclude: ["Archived/"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "DesignExternal",
            dependencies: [
                "FileKit"
            ],
            path: "Sources/ExternalPackages",
            exclude: ["Archived/"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "DesignUIKit",
            dependencies: [
                .target(name: "DesignCore"),
                .target(name: "DesignExts"),
                .target(name: "DesignExternal"),
                "SnapKit",
                "Nuke"
            ],
            path: "Sources/UIKit",
            exclude: ["Archived/"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "DesignCombineUIKit",
            dependencies: [
                .target(name: "DesignUIKit")
            ],
            path: "Sources/UIKit+Combine",
            exclude: ["Archived/"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "DesignRxUIKit",
            dependencies: [
                .target(name: "DesignUIKit"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift")
            ],
            path: "Sources/UIKit+Rx",
            exclude: ["Archived/"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "TestBase",
            path: "Tests/TestBase"
        ),
        .testTarget(
            name: "DesignCoreTests",
            dependencies: [
                .target(name: "DesignCore"),
                .target(name: "TestBase")
            ],
            path: "Tests/Core"
        ),
        .testTarget(
            name: "DesignExtsTests",
            dependencies: [
                .target(name: "DesignExts")
            ],
            path: "Tests/Exts"
        ),
        .testTarget(
            name: "DesignExternalTests",
            dependencies: [
                .target(name: "DesignExternal")
            ],
            path: "Tests/External"
        ),
        .testTarget(
            name: "DesignUIKitTests",
            dependencies: [
                .target(name: "DesignUIKit")
            ],
            path: "Tests/UIKit"
        ),
        .testTarget(
            name: "DesignCombineUIKitTests",
            dependencies: [
                .target(name: "DesignCombineUIKit")
            ],
            path: "Tests/UIKitCombine"
        ),
        .testTarget(
            name: "DesignRxUIKitTests",
            dependencies: [
                .target(name: "DesignRxUIKit")
            ],
            path: "Tests/UIKitRx"
        )
    ]
)
