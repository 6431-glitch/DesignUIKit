//
//  FStack+Rx.swift
//  DesignRxUIKit
//
//  Created by Duke Nguyen on 2024/07/12.
//
//  Provides RxSwift extensions for binding reactive data to `FStack` components.
//  Enables dynamic UI updates using reactive streams and compact renderer closures.
//

import DesignUIKit

public extension FStack {
    /// Binds a reactive data source to the stack view's arranged subviews using the given renderer.
    ///
    /// - Parameters:
    ///   - dataPublisher: A `Driver` that emits an array of data items to display.
    ///   - renderer: A closure that takes each data item and returns an optional `FBodyComponent`.
    /// - Returns: Self, allowing for method chaining.
    func bind<Content>(to dataPublisher: Driver<[Content]>, content renderer: @escaping (Content) -> FBodyComponent?) -> Self {
        dataPublisher.map { $0.compactMap(renderer) }.drive(onNext: { [weak self] in
            guard let self else { return }
            arrangedContents = $0
            reload()
        }).disposed(by: disposeBag)
        return self
    }
}

public extension FStack {
    /// Opt-in stable-ID binding; unchanged values retain views without updates.
    @discardableResult
    func bindItems<Item: Equatable, ID: Hashable, View: FBodyComponent>(
        to driver: Driver<[Item]>,
        id: KeyPath<Item, ID>,
        makeView: @escaping (Item) -> View,
        update: @escaping (View, Item) -> Void,
        onInvalidItems: (() -> Void)? = nil
    ) -> Self {
        bind(to: driver) { stack, items in
            if !stack.updateItems(items, id: id, makeView: makeView, update: update) {
                onInvalidItems?()
            }
        }
    }
}
