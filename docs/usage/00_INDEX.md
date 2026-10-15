# Using DesignUIKit

## Start Here
- [Getting started](01_GETTING_STARTED.md): install the package and host a first screen.
- [Bindings](02_BINDINGS.md): update one component with Combine or RxSwift.
- [Dynamic stacks](03_DYNAMIC_STACKS.md): retain views by stable ID.

## Cookbook
- [Forms](04_FORMS.md): validate input without reconstructing controls.
- [Loading states](05_LOADING_STATES.md): retain components and toggle visibility.
- [Reusable lists](06_REUSABLE_LISTS.md): stable IDs and changed-row snapshots.
- [Child controllers](07_CHILD_CONTROLLERS.md): containment through FViewController.
- [Custom layout](08_CUSTOM_LAYOUT.md): avoid competing parent pins.

## Update Reference
- [Choose the smallest update](09_UPDATES.md): timing, lifecycle, and ownership.

- [Diagnostics](10_DIAGNOSTICS.md): actionable input errors and opt-in layout inspection.

## Source Version
- These guides describe refactor/main, including unreleased 1.1.0 improvements.
- Use the local checkout for these examples until a release containing them exists.
- A 1.0.x package dependency does not guarantee the newer keyed-update APIs.

## Product Choice
| Need | Products to add to the app target |
| --- | --- |
| UIKit composition | DesignUIKit |
| Combine bindings | DesignUIKit and DesignCombineUIKit |
| RxSwift bindings | DesignUIKit and DesignRxUIKit |
| Foundation utilities only | DesignCore |
- Import UIKit and each selected product explicitly in the relevant source file.
- UIKit-only consumers do not need a reactive product.

## Engineering Reference
- [Update contracts](../1.1.0/03_UPDATE_CONTRACTS.md) and [binding ownership](../1.1.0/04_BINDINGS.md).
- [Package architecture](../11_ARCHITECTURE.md) and [module scopes](../modules/00_INDEX.md).
