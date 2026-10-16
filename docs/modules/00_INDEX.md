# Module Scopes

Root [architecture](../11_ARCHITECTURE.md) applies to every module.
All source targets exclude their Archived directories.

| Module | Scope | Tests |
| --- | --- | --- |
| DesignCore | [Core](01_CORE.md) | Tests/Core |
| DesignExts | [Extensions](02_EXTS.md) | Tests/Exts |
| DesignExternal | [External exports](03_EXTERNAL.md) | Tests/External |
| DesignUIKit | [UIKit and Fast View](04_UIKIT.md) | Tests/UIKit |
| DesignCombineUIKit | [Combine](05_COMBINE.md) | Tests/UIKitCombine |
| DesignRxUIKit | [RxSwift](06_RX.md) | Tests/UIKitRx |

## Maintenance
- [x] All package library targets have a scope document.
- [x] Module safety contracts remain discoverable without nested AGENTS files.
