# Using DesignUIKit

## Start Here
- [Getting started](01_GETTING_STARTED.md): install the package and host a first screen.
- [Bindings](02_BINDINGS.md): update one component with Combine or RxSwift.
- [Dynamic stacks](03_DYNAMIC_STACKS.md): retain views by stable ID.

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
