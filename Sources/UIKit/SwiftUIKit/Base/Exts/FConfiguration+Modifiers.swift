import UIKit

extension FConfiguration {
    func restoreModifiers() {
        let restorations = modifierRestorations
        modifierRestorations.removeAll()
        restorations.reversed().forEach { $0() }
    }

    func applyModifiers(to view: FBodyComponent) {
        restoreModifiers()
        let inherited = clearModifiers ? [] : (view.superview?.configuration?.effectiveModifiers ?? [])
        for modifier in inherited {
            let restore = restoration(for: modifier, on: view)
            modifier.body(view)
            if let restore { modifierRestorations.append(restore()) }
        }
        for modifier in modifiers {
            let restore = restoration(for: modifier, on: view)
            modifier.body(view)
            if let restore { modifierRestorations.append(restore()) }
        }
    }

    // Capture before and after values so a later direct change is not overwritten
    // while detaching inherited styles. Arbitrary custom side effects are caller-owned.
    private func restoration(for modifier: FModifier, on view: FBodyComponent) -> (() -> () -> Void)? {
        if modifier is FFontModifier, let text = view as? Calligraphiable {
            let original = text.fontWrapper
            return { [weak text] in
                let applied = text?.fontWrapper
                return { [weak text] in
                    if text?.fontWrapper == applied { text?.fontWrapper = original }
                }
            }
        }
        if modifier is FSafeAreaModifier {
            let original = shouldIgnoreSafeArea
            return { [weak self] in
                let applied = self?.shouldIgnoreSafeArea
                return { [weak self] in
                    if self?.shouldIgnoreSafeArea == applied { self?.shouldIgnoreSafeArea = original }
                }
            }
        }
        if modifier is FBackgroundModifier {
            let original = backgroundColor
            let originalKey = (view as? FThemableBackground)?.backgroundKey
            return { [weak self, weak view] in
                let applied = self?.backgroundColor
                let appliedKey = (view as? FThemableBackground)?.backgroundKey
                return { [weak self, weak view] in
                    let themed = view as? FThemableBackground
                    guard themed?.backgroundKey?.name == appliedKey?.name,
                          appliedKey != nil || self?.backgroundColor == applied else { return }
                    themed?.backgroundKey = originalKey
                    self?.backgroundColor = original
                    if originalKey != nil { themed?.apply(theme: ThemeSystem.shared) }
                }
            }
        }
        if modifier is FForegroundModifier, let themed = view as? FThemableForeground {
            let original = Self.foregroundColor(of: view)
            let originalKey = themed.foregroundKey
            return { [weak view, weak themed] in
                let applied = view.flatMap { Self.foregroundColor(of: $0) }
                let appliedKey = themed?.foregroundKey
                return { [weak view, weak themed] in
                    guard let view, let themed,
                          themed.foregroundKey?.name == appliedKey?.name,
                          appliedKey != nil || Self.foregroundColor(of: view) == applied else { return }
                    themed.foregroundKey = originalKey
                    if let original { themed.foreground(original) }
                    if originalKey != nil { themed.apply(theme: ThemeSystem.shared) }
                }
            }
        }
        return nil
    }

    private static func foregroundColor(of view: UIView) -> UIColor? {
        switch view {
        case let label as UILabel: return label.textColor
        case let field as UITextField: return field.textColor
        case let text as UITextView: return text.textColor
        case let button as UIButton: return button.titleColor(for: .normal)
        default: return nil
        }
    }
}
