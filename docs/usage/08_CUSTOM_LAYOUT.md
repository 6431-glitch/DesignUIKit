# Recipe: Custom Layout Without Competing Parent Pins

Disable automatic parent attachment when your own constraints control positioning.
```swift
import UIKit
import DesignUIKit
let host = UIView()
let badge = FLabel("New")
    .attachToParent(false)
    .layout { make, parent in
        make.top.leading.equalTo(parent.safeAreaLayoutGuide).inset(16)
        make.height.equalTo(32)
    }
host.addSubview(badge)
badge.frame(width: 80)
badge.configuration?.applyLayout()
```
- frame(width:) configures an Auto Layout dimension; it is not UIView.frame assignment.
- Layout setters coalesce until layout/the next main-queue turn; applyLayout flushes.
- The toolkit retains its own unchanged constraints and leaves consumer constraints.
- Prefer either automatic parent edges or explicit positioning for the same axis.
- Padding and offset calls add to existing values; configure them once rather than
  repeatedly applying the same additive modifier inside a binding.
- Custom layout closures should install only their intended constraints and avoid
  side effects; reparenting may execute the closure again for the new parent.
