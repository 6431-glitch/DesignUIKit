# DesignUIKit Scope

## Ownership
- Sources/UIKit/Components/BaseUI: shared themed UIKit subclasses.
- Components/Systems: ThemeSystem, FontSystem, theme keys, and spacing.
- SwiftUIKit: FComponent, FConfigurable, FView, modifiers, and F* components.
- ListView: reusable table/collection infrastructure and model contracts.

## Contracts
- Preserve fluent APIs and public source compatibility.
- Centralize theme/font registration in system classes.
- Keep FViewController containment idempotent: do not duplicate willMove before
  addChild, and do not re-add a child already attached to the same parent.
- Use FViewController.parent(...) and its internal attach/detach flow.
- Guard section/item indices during diffable snapshot and selection timing.
- FButton.tapEvent uses touchUpInside on iOS and primaryActionTriggered on
  Mac Catalyst (under evaluation).
- Preserve platform guards and avoid Archived APIs.

## Composition
```swift
FVStack(spacing: 8) {
    FLabel("Title").foreground(.label)
    FButton("Continue") { print("tap") }
}
```

## Update Direction
- Prefer direct property updates and retention of unchanged child views.
- Follow [update contracts](../1.1.0/03_UPDATE_CONTRACTS.md) for keyed stacks and reload.

## Validation
- Tests/UIKit covers lifecycle, selection, adapters, and components.
- Add behavior tests and follow [validation](../14_TESTING.md).
