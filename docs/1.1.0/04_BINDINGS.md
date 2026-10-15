# Binding Ownership

## Compatibility
- Existing bind(to:next:error:complete:) signatures remain available.
- Unkeyed calls append subscriptions tied to the view lifetime, as before.
- Named binding slots are opt-in and separate from the existing bag/set.
- Resetting disposeBag/cancellables affects unkeyed bindings; cancel named slots
  explicitly through the matching cancellation API.

## Named Subscriptions
```swift
label.bind(to: titlePublisher, key: "title") { label, title in
    label.text = title
}
label.cancelCombineBinding(for: "title")
```
- Reusing a key cancels the previous subscription in that framework's slot.
- Different keys and unkeyed subscriptions are unaffected.
- Rx uses the same key argument with Driver and cancelRxBinding(for:).
- Rx slots are registered before synchronous initial delivery so handlers may
  cancel or replace their own subscription safely.
- View deallocation cancels named subscriptions in both integrations.

## Keyed Collections
```swift
stack.bindItems(to: rowsPublisher, key: "rows", id: \.id,
    makeView: { FLabel($0.title) },
    update: { (label: FLabel, row: Row) in label.text = row.title },
    onInvalidItems: { /* handle duplicate IDs or reused view instances */ })
```
- bindItems is available for Combine publishers and Rx Drivers of Equatable items.
- Validation failures preserve installed content and call onInvalidItems if provided.
- Delivery updates UI on the main thread; retained equal values skip update.

## Consumer Responsibilities
- Use the component argument in handlers rather than strongly capturing the view.
- Closures supplied by consumers can still create reference cycles if they capture
  the owning view/controller strongly; capture those owners weakly when needed.
- Keep handlers short; move expensive transformations off the UI thread upstream.
