//
//  File.swift
//  ComponentSystem
//
//  Created by Duke Nguyen on 26/9/24.
//

import UIKit
import Combine
import DesignUIKit
import DesignCore

public typealias FBinder<Subject> = AnyPublisher<Subject, Never>

@MainActor public protocol Combinable: AnyObject {
    var cancellables: Set<AnyCancellable> { get set }
}

extension UIView: Combinable {
    private static let keyedCombineBindings = ObjectAssociation<StructWrapper<[AnyHashable: AnyCancellable]>>()

    var combineBindingSlots: [AnyHashable: AnyCancellable] {
        get { Self.keyedCombineBindings[self]?.value ?? [:] }
        set { Self.keyedCombineBindings[self] = .init(value: newValue) }
    }

    static let cancellables = ObjectAssociation<StructWrapper<Set<AnyCancellable>>>()

    public var cancellables: Set<AnyCancellable> {
        get {
            if let cancellables = Self.cancellables[self]?.value {
                return cancellables
            }
            let cancellables = Set<AnyCancellable>()
            Self.cancellables[self] = .init(value: cancellables)
            return cancellables
        }
        set { Self.cancellables[self] = .init(value: newValue) }
    }
}

public extension FComponent where Self: UIView, Self: Combinable {
    /// Cancels only the named binding. Unkeyed and differently keyed bindings survive.
    func cancelCombineBinding(for key: AnyHashable) {
        let subscription = combineBindingSlots.removeValue(forKey: key)
        subscription?.cancel()
    }

    /// Unkeyed calls append; keyed calls replace the subscription in that slot.
    @discardableResult func bind<Subject, Failure>(
        to publisher: AnyPublisher<Subject, Failure>,
        next: @escaping (Self, Subject) -> Void,
        error: ((Failure) -> Void)? = nil,
        complete: (() -> Void)? = nil
    ) -> Self {
        bind(to: publisher, key: nil, next: next, error: error, complete: complete)
    }

    /// Supplying a key replaces only that slot; nil retains append behavior.
    @discardableResult func bind<Subject, Failure>(
        to publisher: AnyPublisher<Subject, Failure>,
        key: AnyHashable?,
        next: @escaping (Self, Subject) -> Void,
        error: ((Failure) -> Void)? = nil,
        complete: (() -> Void)? = nil
    ) -> Self {
        if let key { cancelCombineBinding(for: key) }
        let subscription = publisher.receive(on: DispatchQueue.main).sink { completion in
            switch completion {
            case .failure(let failure):
                error?(failure)
            case .finished:
                complete?()
            }
        } receiveValue: { [weak self] subject in
            guard let self = self else { return }
            next(self, subject)
        }
        if let key {
            combineBindingSlots[key] = subscription
        } else {
            subscription.store(in: &cancellables)
        }
        return self
    }
}
