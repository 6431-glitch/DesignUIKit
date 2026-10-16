# DesignExternal Scope

## Ownership
- Sources/ExternalPackages is a thin external-package export surface.
- FileKit.swift re-exports FileKit with @_exported import FileKit.

## Contracts
- import DesignExternal continues exposing Path and related FileKit APIs.
- Keep wrappers thin, reusable, and testable.
- Do not add feature business logic or UI component responsibilities.
- Preserve public source compatibility and avoid Archived APIs.

## Usage
```swift
import DesignExternal
let temporaryPath = Path.uniqueTemporary
```

## Validation
- Add behavior tests in Tests/External; follow [validation](../14_TESTING.md).
