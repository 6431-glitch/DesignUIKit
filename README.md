# DesignUIKit

A modular UIKit toolkit with fluent composition, themes, reusable lists, and
optional Combine or RxSwift bindings.

## Requirements
- Swift package tools: 5.9.
- iOS 13+ or tvOS 15+; platform-specific APIs keep their availability guards.
- An Xcode toolchain supporting Swift 5.9 and the selected platform SDK.

## Modules
| Product | Direct package dependencies | Purpose |
| --- | --- | --- |
| DesignCore | Logging | Builders, preferences, associated storage, utilities |
| DesignExts | DesignCore | Color, geometry, and layer extensions |
| DesignExternal | FileKit | Thin external-library exports |
| DesignUIKit | DesignCore, DesignExts, DesignExternal, SnapKit, Nuke | Components, styling, lists |
| DesignCombineUIKit | DesignUIKit | Combine bindings and MVVM blueprints |
| DesignRxUIKit | DesignUIKit, RxSwift, RxCocoa | Rx bindings and MVVM blueprints |

## Swift Package Manager
```swift
.package(url: "https://github.com/duke6431/DesignUIKit.git", from: "1.0.0")
```
Add only the products your target needs, for example:
```swift
.product(name: "DesignUIKit", package: "DesignUIKit"),
.product(name: "DesignCombineUIKit", package: "DesignUIKit"),
```
The [CocoaPods specification](DesignUIKit.podspec) has separate distribution metadata;
its release validation is tracked in the version checklist.

## Composition
```swift
FVStack(spacing: 8) {
    FLabel("Welcome").foreground(.label)
    FButton("Continue") { print("tap") }
}
```

## Documentation
- [Getting started](docs/usage/00_INDEX.md): install, compose, and update your first screen.
- [Index](docs/00_INDEX.md): architecture, module scopes, testing, and progress.
- [1.1.0 improvements](docs/1.1.0/00_INDEX.md): implementation and release acceptance.
- [Selective updates](docs/1.1.0/03_UPDATE_CONTRACTS.md): update scope and keyed stacks.
- [Binding ownership](docs/1.1.0/04_BINDINGS.md): named subscriptions and cancellation.
- [Contributing agreement](AGENTS.md).

Created by Duke Nguyen. [MIT License](LICENSE).
