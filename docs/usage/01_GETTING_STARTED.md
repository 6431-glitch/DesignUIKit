# Getting Started

## Install This Checkout
In Xcode, add the local DesignUIKit folder as a package dependency and select
DesignUIKit for your app target. In an app's Package.swift, the equivalent is:
```swift
.package(path: "../DesignUIKit")
```
```swift
.product(name: "DesignUIKit", package: "DesignUIKit")
```
The path is relative to the consuming package. These guides use unreleased branch
APIs; see [source version and product choices](00_INDEX.md).

## First Screen
Add this controller to your app and present/push WelcomeViewController from your
existing navigation or app entry flow. The toolkit uses UIKit views and controllers.
```swift
import UIKit
import DesignUIKit

@MainActor
final class WelcomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let content = FVStack(spacing: 12) {
            FLabel("Welcome").font(.boldSystemFont(ofSize: 24))
            FButton("Continue") { print("Continue tapped") }
        }
        .padding(24)
        .ignore(edges: .bottom)
        view.addSubview(content)
    }
}
```
- Components apply their parent layout when attached; keep UIKit work on main.
- Here the stack pins its top/side edges to the safe area and uses its content height.
- Fluent modifiers mutate the existing component; retain references for later updates.

## Continue
- [Bind one label](02_BINDINGS.md) or [update a dynamic stack](03_DYNAMIC_STACKS.md).
