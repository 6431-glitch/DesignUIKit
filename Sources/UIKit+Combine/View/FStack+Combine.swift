import Combine
import DesignUIKit

public extension FStack {
    /// Opt-in stable-ID binding; existing unkeyed bindings remain available.
    @discardableResult
    func bindItems<Item: Equatable, ID: Hashable, View: FBodyComponent>(
        to publisher: AnyPublisher<[Item], Never>,
        key: AnyHashable? = nil,
        id: KeyPath<Item, ID>,
        makeView: @escaping (Item) -> View,
        update: @escaping (View, Item) -> Void,
        onInvalidItems: (() -> Void)? = nil
    ) -> Self {
        bindItems(to: publisher, key: key, id: id, makeView: makeView, update: update,
                  onUpdateError: { _ in onInvalidItems?() })
    }

    /// Receives structured validation failures while retaining the installed content.
    @discardableResult
    func bindItems<Item: Equatable, ID: Hashable, View: FBodyComponent>(
        to publisher: AnyPublisher<[Item], Never>,
        key: AnyHashable? = nil,
        id: KeyPath<Item, ID>,
        makeView: @escaping (Item) -> View,
        update: @escaping (View, Item) -> Void,
        onUpdateError: @escaping (FStackUpdateError) -> Void
    ) -> Self {
        bind(to: publisher, key: key) { stack, items in
            if case let .failure(error) = stack.updateItemsResult(items, id: id, makeView: makeView, update: update) {
                onUpdateError(error)
            }
        }
    }
}
