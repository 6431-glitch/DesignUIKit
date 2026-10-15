# DesignCombineUIKit Scope

## Ownership
- Sources/UIKit+Combine/BaseBlocks: ViewModel/controller/coordinator blueprints
  and UseCase, CompletableUseCase, StreamUseCase contracts.
- View: FBinder, Combinable, component binding, and view-specific conveniences.
- Combine+: operator helpers and FObservedPreference.

## Contracts
- Deliver component binding updates on the main queue.
- Preserve associated-object-backed UIView cancellables storage.
- Preserve FBinder and extension initializer source compatibility.
- FObservedPreference takes FPreferenceKey and writes changes to UserDefaults.
- Keep operators free of side effects beyond documented transformations.
- BaseBlocks define architecture contracts; inject concrete use cases from
  consumer feature/domain modules; one ViewModel may coordinate several.
- Avoid Archived APIs and feature/domain implementations in this target.

- Named subscriptions support scoped replacement/cancellation; see [ownership](../1.1.0/04_BINDINGS.md).

## Usage
```swift
button.bind(to: titlePublisher) { button, title in
    button.setTitle(title, for: .normal)
}
```

## Validation
- Tests/UIKitCombine covers operators, preferences, and use-case contracts.
- Add behavior tests and follow [validation](../14_TESTING.md).
