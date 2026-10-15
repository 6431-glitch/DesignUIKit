import UIKit

/// The sole type-erasure boundary for FStack's generic item/view updates.
/// Each entry keeps its model snapshot and view together under one stable ID.
@MainActor
struct FKeyedContentState {
    private struct Entry {
        let itemSnapshot: Any
        let view: FBodyComponent
    }

    private var entries: [AnyHashable: Entry] = [:]

    mutating func store<Item, ID: Hashable>(_ item: Item, id: ID, view: FBodyComponent) {
        entries[AnyHashable(id)] = Entry(itemSnapshot: item, view: view)
    }

    func existingView<Item, ID: Hashable, View: FBodyComponent>(
        for id: ID,
        item: Item,
        as viewType: View.Type,
        areEquivalent: (Item, Item) -> Bool
    ) -> (view: View, isUnchanged: Bool)? {
        guard let entry = entries[AnyHashable(id)], let view = entry.view as? View else { return nil }
        let isUnchanged = (entry.itemSnapshot as? Item).map { areEquivalent($0, item) } ?? false
        return (view, isUnchanged)
    }
}
