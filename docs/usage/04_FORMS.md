# Recipe: A Form With Local Validation

Create the controls once. Update the existing button when the field changes.
The host represents your screen's root view.
```swift
import UIKit
import DesignUIKit
let host = UIView()
let save = FButton("Save") { print("Save requested") }
save.isEnabled = false
let name = FTextField("Name", "")
    .frame(height: 44)
    .onChange { [weak save] value in
        save?.isEnabled = !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
let form = FVStack(spacing: 12) {
    FLabel("Profile")
    name
    save
}
.padding(24)
.ignore(edges: .bottom)
host.addSubview(form)
```
- The callback captures the button weakly; it does not reconstruct the form.
- In a feature, send submitted values to your ViewModel/domain use case.
- Programmatically assigning name.text does not simulate a user editing event;
  update validation explicitly when applying programmatic values.
- Keep controls or the form as screen-owned properties when needed later.
