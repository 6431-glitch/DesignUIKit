import Combine
import DesignUIKit

public extension FStack {
    /// Opt-in stable-ID binding; existing unkeyed bindings remain available.
    @discardableResult
    func bindItems<Item: Equatable, ID: Hashable, View: FBodyComponent>(
        to publisher: AnyPublisher<[Item], Never>,
        id: KeyPath<Item, ID>,
        makeView: @escaping (Item) -> View,
        update: @escaping (View, Item) -> Void,
        onInvalidItems: (() -> Void)? = nil
    ) -> Self {
        bind(to: publisher) { stack, items in
            if !stack.updateItems(items, id: id, makeView: makeView, update: update) {
                onInvalidItems?()
            }
        }
    }
}
