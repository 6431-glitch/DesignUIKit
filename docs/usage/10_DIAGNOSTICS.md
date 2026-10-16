# Diagnose a Rejected Update or Layout Rule

## Keyed Input and Configuration
Use updateItemsResult when you need a reason instead of updateItems' Bool.
```swift
import UIKit
import DesignUIKit
let stack = FVStack(arrangedContents: [])
let result = stack.updateItemsResult([1, 1], id: \.self,
    makeView: { FLabel(String($0)) }, update: { (_: FLabel, _: Int) in })
if case let .failure(error) = result {
    print(error.localizedDescription)
}
let badge = FLabel("New").frame(width: 80)
for issue in badge.layoutDiagnostics() { print(issue.message) }
badge.ignore(edges: .trailing)
```
- duplicateIdentifier reports the first/repeated input positions; use unique stable IDs.
- reusedView reports positions sharing a view; create a distinct view for each new ID.
- Indices are zero-based. IDs are validated before factories run; factories may run
  before view-reuse rejection, so keep them free of unrelated side effects.
- Rejected input leaves installed content intact and does not invoke retained updates.
- Layout diagnostics inspect known fixed-size/parent-pin combinations without mutation.
- These are potential conflicts, not solver results: actual dimensions, custom
  constraints, and other UIKit constraints are outside their scope.

## Reactive Validation
```swift
import UIKit
import Combine
import DesignUIKit
import DesignCombineUIKit
let items = CurrentValueSubject<[Int], Never>([])
let stack = FVStack(arrangedContents: [])
stack.bindItems(to: items.eraseToAnyPublisher(), key: "items", id: \.self,
    makeView: { FLabel(String($0)) }, update: { (_: FLabel, _: Int) in },
    onUpdateError: { print($0.localizedDescription) })
items.send([1, 1])
```
- Rx Driver bindings support the same onUpdateError label.
- onUpdateError reports keyed-input validation failures.
- Existing onInvalidItems callbacks and Bool updates keep their behavior.
- Named cancellation still applies; neither diagnostics API logs or throws automatically.
- [Choose the smallest update](09_UPDATES.md) and [custom layout](08_CUSTOM_LAYOUT.md).
