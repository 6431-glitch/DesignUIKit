import UIKit

/// A built-in modifier's reversible state. Custom side effects remain modifier-owned.
@MainActor
protocol FModifierRestoring {
    func captureAppliedState()
    func restoreIfUnchanged()
}

/// Names the three stages of modifier restoration without nesting closure factories.
/// Accessors must capture the target weakly so snapshots never extend a view's lifetime.
@MainActor
final class FModifierSnapshot<Value>: FModifierRestoring {
    private let original: Value
    private var applied: Value?
    private let read: () -> Value?
    private let restore: (Value) -> Void
    private let matchesApplied: (Value, Value) -> Bool

    init?(
        read: @escaping () -> Value?,
        restore: @escaping (Value) -> Void,
        matchesApplied: @escaping (Value, Value) -> Bool
    ) {
        guard let original = read() else { return nil }
        self.original = original
        self.read = read
        self.restore = restore
        self.matchesApplied = matchesApplied
    }

    func captureAppliedState() {
        applied = read()
    }

    func restoreIfUnchanged() {
        guard let applied, let current = read(), matchesApplied(current, applied) else { return }
        restore(original)
    }
}

/// Theme keys identify a style even when a theme change replaces its resolved color.
@MainActor
struct FModifierColorState {
    let color: UIColor?
    let key: ThemeKey?

    static func matchesApplied(_ current: Self, _ applied: Self) -> Bool {
        current.key?.name == applied.key?.name && (applied.key != nil || current.color == applied.color)
    }
}
