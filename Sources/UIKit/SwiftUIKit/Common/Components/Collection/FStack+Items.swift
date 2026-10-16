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
        if case .success = updateItemsResult(items, id: id, areEquivalent: areEquivalent, makeView: makeView, update: update) {
            return true
        }
        return false
    }

    /// Reports actionable rejection details without changing the existing Bool API.
    /// Duplicate IDs are rejected before makeView runs. Invalid view reuse is
    /// rejected before retained views are updated or content is installed.
    func updateItemsResult<Item: Equatable, ID: Hashable, View: FBodyComponent>(
        _ items: [Item],
        id: KeyPath<Item, ID>,
        makeView: (Item) -> View,
        update: (View, Item) -> Void
    ) -> Result<Void, FStackUpdateError> {
        updateItemsResult(items, id: id, areEquivalent: ==, makeView: makeView, update: update)
    }

    /// Custom equality variant for immutable snapshots that are not Equatable.
    func updateItemsResult<Item, ID: Hashable, View: FBodyComponent>(
        _ items: [Item],
        id: KeyPath<Item, ID>,
        areEquivalent: (Item, Item) -> Bool,
        makeView: (Item) -> View,
        update: (View, Item) -> Void
    ) -> Result<Void, FStackUpdateError> {
        let ids = items.map { $0[keyPath: id] }
        if let duplicate = firstDuplicate(in: ids) {
            return .failure(.duplicateIdentifier(firstIndex: duplicate.first, duplicateIndex: duplicate.repeated))
        }
        let plan = prepareKeyedUpdate(items, ids: ids, areEquivalent: areEquivalent, makeView: makeView)
        if let error = plan.validationError { return .failure(error) }

        plan.updates.forEach { update($0.view, $0.item) }
        installKeyedContent(plan.content, state: plan.state)
        return .success(())
    }
}

private extension FStack {
    func prepareKeyedUpdate<Item, ID: Hashable, View: FBodyComponent>(
        _ items: [Item],
        ids: [ID],
        areEquivalent: (Item, Item) -> Bool,
        makeView: (Item) -> View
    ) -> FKeyedUpdatePlan<Item, View> {
        var plan = FKeyedUpdatePlan<Item, View>()
        for (id, item) in zip(ids, items) {
            let view: View
            if let retained = keyedContentState.existingView(for: id, item: item, as: View.self, areEquivalent: areEquivalent) {
                view = retained.view
                if !retained.isUnchanged { plan.updates.append((view, item)) }
            } else {
                view = makeView(item)
            }
            plan.state.store(item, id: id, view: view)
            plan.content.append(view)
        }
        return plan
    }
}

/// Prepared before any retained view is mutated or installed, so invalid input
/// cannot partially update the installed hierarchy.
@MainActor
private struct FKeyedUpdatePlan<Item, View: FBodyComponent> {
    var content: FBody = []
    var state = FKeyedContentState()
    var updates: [(view: View, item: Item)] = []

    var validationError: FStackUpdateError? {
        guard let duplicate = firstDuplicate(in: content.map { ObjectIdentifier($0) }) else { return nil }
        return .reusedView(firstIndex: duplicate.first, duplicateIndex: duplicate.repeated)
    }
}

private func firstDuplicate<Value: Hashable>(in values: [Value]) -> (first: Int, repeated: Int)? {
    var positions: [Value: Int] = [:]
    for (index, value) in values.enumerated() {
        if let first = positions[value] { return (first, index) }
        positions[value] = index
    }
    return nil
}
