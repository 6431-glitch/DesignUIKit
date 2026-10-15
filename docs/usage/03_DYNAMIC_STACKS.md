# Update a Dynamic Stack

Use stable IDs and immutable values to retain unchanged view instances.
```swift
import UIKit
import DesignUIKit
struct Row: Equatable {
    let id: Int
    let title: String
}
let stack = FVStack(arrangedContents: [])
func render(_ rows: [Row]) {
    stack.updateItems(rows, id: \.id,
        makeView: { FLabel($0.title) },
        update: { (label: FLabel, row: Row) in label.text = row.title })
}
render([Row(id: 1, title: "First"), Row(id: 2, title: "Second")])
render([Row(id: 2, title: "Updated"), Row(id: 1, title: "First")])
```
- Attach stack to your screen once; subsequent render calls update that instance.
- New IDs call makeView, which must return a fully configured distinct view.
- Changed values for retained IDs call update; equal values skip the callback.
- Reorders preserve retained instances, including local text input state.
- Duplicate IDs or reused view instances reject the update and return false.
- Explicit closure types avoid ambiguity when Swift cannot infer a component type.

## Data Rules
- Keep IDs stable across title/content changes; array positions are poor mutable IDs.
- Use new value snapshots rather than mutating a shared reference in place.
- Non-Equatable models may supply areEquivalent: explicitly.
- Assigning arrangedContents manually clears keyed history.
- Combine/Rx consumers can use bindItems with the same ID/create/update rules.
