# Recipe: A Loading State

Keep both components alive and change visibility instead of rebuilding the screen.
```swift
import UIKit
import DesignUIKit
let spinner = UIActivityIndicatorView(style: .medium)
let indicator = FContainer(content: spinner)
let result = FLabel("Ready")
let content = FVStack(spacing: 12) {
    indicator
    result
}
let host = UIView()
host.addSubview(content)
func setLoading(_ loading: Bool) {
    indicator.isHidden = !loading
    result.isHidden = loading
    if loading {
        spinner.startAnimating()
    } else {
        spinner.stopAnimating()
    }
}
setLoading(true)
result.text = "Loaded"
setLoading(false)
```
- Attach content once to your screen and keep the controls in its owner.
- FContainer embeds an ordinary UIKit control within Fast View composition.
- Hiding an arranged view lets UIStackView update its arrangement.
- A network completion should call setLoading on main or use a UI-safe binding.
- No reload is needed for the text or visibility changes shown here.
