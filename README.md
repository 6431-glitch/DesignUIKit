# DesignUIKit

A modular UIKit toolkit with fluent composition, themes, reusable lists, and
optional Combine or RxSwift bindings.

## Requirements
- Swift package tools: 5.9.
- iOS 13+; Mac Catalyst builds and tests pass; manual validation is pending. Native AppKit and tvOS are unsupported.
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
Swift Package Manager is the supported distribution method.

## Composition
```swift
FVStack(spacing: 8) {
    FLabel("Welcome").foreground(.label)
    FButton("Continue") { print("tap") }
}
```

## Documentation
- [User guides](docs/usage/00_INDEX.md): onboarding, recipes, updates, and diagnostics.
- [Index](docs/00_INDEX.md): architecture, module scopes, testing, and progress.
- [1.1.0 improvements](docs/1.1.0/00_INDEX.md): implementation and release acceptance.
- [Choosing updates](docs/usage/09_UPDATES.md): mutation, layout, content, and reload.
- [Binding ownership](docs/1.1.0/04_BINDINGS.md): named subscriptions and cancellation.
- [Contributing agreement](AGENTS.md).

Created by Duke Nguyen. [MIT License](LICENSE).
