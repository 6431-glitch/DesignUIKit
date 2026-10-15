import UIKit

public extension FStack {
    /// Reconciles stable IDs. Unchanged Equatable values skip the update closure.
    /// makeView must return a fully configured, distinct view for each new ID.
    /// Returns false for duplicate IDs or reused view instances, leaving the
    /// installed content unchanged. Existing unkeyed arranged content is replaced.
    @discardableResult
    func updateItems<Item: Equatable, ID: Hashable, View: FBodyComponent>(
        _ items: [Item],
        id: KeyPath<Item, ID>,
        makeView: (Item) -> View,
        update: (View, Item) -> Void
    ) -> Bool {
        updateItems(items, id: id, areEquivalent: ==, makeView: makeView, update: update)
    }

    /// Custom equality supports models that cannot conform to Equatable.
    /// Only changed retained values call update; inserted values call makeView.
    /// Models must be immutable snapshots for equality comparisons to be meaningful.
    @discardableResult
    func updateItems<Item, ID: Hashable, View: FBodyComponent>(
        _ items: [Item],
        id: KeyPath<Item, ID>,
        areEquivalent: (Item, Item) -> Bool,
        makeView: (Item) -> View,
        update: (View, Item) -> Void
    ) -> Bool {
        let ids = items.map { AnyHashable($0[keyPath: id]) }
        guard Set(ids).count == ids.count else { return false }
        var nextViews: [AnyHashable: FBodyComponent] = [:]
        var nextItems: [AnyHashable: Any] = [:]
        var ordered: FBody = []
        var changes: [(View, Item)] = []
        for (key, item) in zip(ids, items) {
            let view: View
            if let existing = keyedViews[key] as? View {
                view = existing
                if let previous = keyedItems[key] as? Item, areEquivalent(previous, item) {
                    // Preserve local view state for unchanged snapshots.
                } else {
                    changes.append((view, item))
                }
            } else {
                view = makeView(item)
            }
            nextViews[key] = view
            nextItems[key] = item
            ordered.append(view)
        }
        guard Set(ordered.map { ObjectIdentifier($0) }).count == ordered.count else { return false }
        changes.forEach { update($0.0, $0.1) }
        arrangedContents = ordered
        keyedViews = nextViews
        keyedItems = nextItems
        updateContent()
        return true
    }
}
