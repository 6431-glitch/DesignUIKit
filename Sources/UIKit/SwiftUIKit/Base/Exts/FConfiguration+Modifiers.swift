import UIKit

extension FConfiguration {
    func restoreModifiers() {
        let snapshots = appliedModifierSnapshots
        appliedModifierSnapshots.removeAll()
        snapshots.reversed().forEach { $0.restoreIfUnchanged() }
    }

    func applyModifiers(to view: FBodyComponent) {
        restoreModifiers()
        let inherited = clearModifiers ? [] : (view.superview?.configuration?.effectiveModifiers ?? [])
        // Parent styles are applied first; locally declared modifiers take precedence.
        for modifier in inherited + modifiers {
            let snapshot = makeSnapshot(for: modifier, on: view)
            modifier.body(view)
            snapshot?.captureAppliedState()
            if let snapshot { appliedModifierSnapshots.append(snapshot) }
        }
    }

    private func makeSnapshot(for modifier: FModifier, on view: FBodyComponent) -> FModifierRestoring? {
        switch modifier {
        case is FFontModifier:
            guard let text = view as? Calligraphiable else { return nil }
            return FModifierSnapshot(
                read: { [weak text] in text?.fontWrapper },
                restore: { [weak text] font in text?.fontWrapper = font },
                matchesApplied: ==)
        case is FSafeAreaModifier:
            return FModifierSnapshot(
                read: { [weak self] in self?.shouldIgnoreSafeArea },
                restore: { [weak self] value in self?.shouldIgnoreSafeArea = value },
                matchesApplied: ==)
        case is FBackgroundModifier:
            return backgroundSnapshot(for: view)
        case is FForegroundModifier:
            return foregroundSnapshot(for: view)
        default:
            // Arbitrary custom mutations cannot be reversed by the toolkit.
            return nil
        }
    }

    private func backgroundSnapshot(for view: FBodyComponent) -> FModifierRestoring? {
        FModifierSnapshot(
            read: { [weak self, weak view] in
                guard let self, let view else { return nil }
                return FModifierColorState(color: backgroundColor, key: (view as? FThemableBackground)?.backgroundKey)
            },
            restore: { [weak self, weak view] state in
                let themed = view as? FThemableBackground
                themed?.backgroundKey = state.key
                self?.backgroundColor = state.color ?? .clear
                if state.key != nil { themed?.apply(theme: ThemeSystem.shared) }
            },
            matchesApplied: FModifierColorState.matchesApplied)
    }

    private func foregroundSnapshot(for view: FBodyComponent) -> FModifierRestoring? {
        guard let themed = view as? FThemableForeground else { return nil }
        return FModifierSnapshot(
            read: { [weak view, weak themed] in
                guard let view, let themed else { return nil }
                return FModifierColorState(color: Self.foregroundColor(of: view), key: themed.foregroundKey)
            },
            restore: { [weak themed] state in
                themed?.foregroundKey = state.key
                if let color = state.color { themed?.foreground(color) }
                if state.key != nil { themed?.apply(theme: ThemeSystem.shared) }
            },
            matchesApplied: FModifierColorState.matchesApplied)
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
