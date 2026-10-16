# Recipe: Embed a Child Controller

Let FViewController own containment notifications and layout of the child view.
```swift
import UIKit
import DesignUIKit
@MainActor
final class ParentViewController: UIViewController {
    private let child = UIViewController()
    private var embedded: FViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        let host = FViewController(child).parent(self).padding(16)
        embedded = host
        view.addSubview(host)
    }

    func stopEmbedding() {
        embedded?.removeFromSuperview()
        embedded = nil
    }
}
```
- Set parent before attaching the host so the child joins the correct controller.
- Removing the host detaches the child and clears the host's parent reference.
- Call parent(...) again before reusing a removed host.
- Keep feature navigation policy in the app/ViewModel/Navigator owner.
