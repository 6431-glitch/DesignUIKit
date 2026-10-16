# Bind One Component

## Combine
Add DesignUIKit and DesignCombineUIKit products to your target.
```swift
import UIKit
import Combine
import DesignUIKit
import DesignCombineUIKit
let title = CurrentValueSubject<String, Never>("Ready")
let label = FLabel()
label.bind(to: title.eraseToAnyPublisher(), key: "title") { label, value in
    label.text = value
}
title.send("Saved")
```
Delivery is scheduled on the main queue. Keep the publisher in your ViewModel or
screen owner; place this same label instance in your hierarchy.

## RxSwift
Add DesignUIKit and DesignRxUIKit products to your target.
```swift
import UIKit
import DesignUIKit
import DesignRxUIKit
let title = BehaviorRelay(value: "Ready")
let label = FLabel()
label.bind(to: title.asDriver(), key: "title") { label, value in
    label.text = value
}
title.accept("Saved")
```
Driver bindings deliver UI changes on main. Both examples update only the label.

## Ownership
- Reusing "title" replaces that named subscription; other slots remain active.
- Unkeyed bind calls append, so repeated setup can produce multiple subscriptions.
- To stop a named binding, call cancelCombineBinding(for:) or cancelRxBinding(for:).
- View deallocation cancels view-owned bindings; avoid strongly capturing the view
  inside its own handler. Use the component argument shown above.
- [Detailed ownership contract](../1.1.0/04_BINDINGS.md).
