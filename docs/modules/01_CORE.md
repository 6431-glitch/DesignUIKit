# DesignCore Scope

## Ownership
- Sources/Core: shared utilities, builders, preferences, attributed strings,
  logging, object association, and collection/date/string extensions.
- Chainable supports reference configuration; SelfCustomizable supports values.
- FBuilder<Node> builds arrays for declarative composition.
- PreferenceItem and PreferenceData use FPreferenceKey and support custom stores.

## Contracts
- Preserve Array[safe:] returning nil outside valid bounds.
- Preserve date parsing/formatting locale behavior (.autoupdatingCurrent).
- Keep FPreferenceKey in preference APIs rather than replacing it with String.
- Retain ObjectAssociation and StructWrapper for extension-backed storage.
- Keep shared utilities independent of UIKit component and reactive targets.
- Preserve public API compatibility and avoid Archived APIs.

## Usage
```swift
let next = state.updated(\.count, with: 2)
let item = items[safe: index]
let text = NSAttributedString.build {
    CommonAttributedString("Hello").font(.systemFont(ofSize: 14))
}
```

## Validation
- Add behavior tests in Tests/Core; follow [validation](../14_TESTING.md).
