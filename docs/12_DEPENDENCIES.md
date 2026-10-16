# Dependencies

[Package.swift](../Package.swift) is the source of truth for this graph.

## Internal and External Targets
| Target | Direct dependencies |
| --- | --- |
| DesignCore | Logging (swift-log) |
| DesignExts | DesignCore |
| DesignExternal | FileKit |
| DesignUIKit | DesignCore, DesignExts, DesignExternal, SnapKit, Nuke |
| DesignCombineUIKit | DesignUIKit; system Combine |
| DesignRxUIKit | DesignUIKit, RxSwift, RxCocoa |

## Declared Package Ranges
- swift-log: from 1.0.0.
- FileKit: next major from 6.1.0.
- SnapKit: next major from 5.0.1.
- Nuke: next major from 12.4.0.
- RxSwift: next major from 6.5.0.
- These are manifest constraints, not claims about resolved versions.

## Rules
- Avoid circular dependencies and feature-specific dependencies.
- Keep DesignExternal lightweight; preserve its FileKit re-export.
- Check deployment compatibility before changing dependency constraints.
- Update this document when Package.swift changes its graph.
