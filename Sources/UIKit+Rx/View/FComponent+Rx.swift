//
//  FComponent+Rx.swift
//  DesignRxUIKit
//
//  Created by Duke Nguyen on 2024/09/26.
//
//  Adds reactive support to UI components with `Reactivable` protocol,
//  providing a `disposeBag` and a `bind` method to subscribe to RxSwift streams.
//

import UIKit
import RxSwift
import DesignUIKit
import DesignCore
import RxCocoa

/// A protocol for UI components that should support RxSwift subscriptions via a `DisposeBag`.
@MainActor public protocol Reactivable: AnyObject {
    /// The `DisposeBag` used to store subscriptions tied to the component's lifecycle.
    var disposeBag: DisposeBag { get set }
}

/// Conforms all `UIView` instances to `Reactivable` using associated objects to manage the `DisposeBag`.
extension UIView: Reactivable {
    private static let keyedRxBindings = ObjectAssociation<StructWrapper<[AnyHashable: FRxBindingSlot]>>()

    fileprivate var rxBindingSlots: [AnyHashable: FRxBindingSlot] {
        get { Self.keyedRxBindings[self]?.value ?? [:] }
        set { Self.keyedRxBindings[self] = .init(value: newValue) }
    }

    static let disposeBag = ObjectAssociation<DisposeBag>()
    
    /// Lazily initializes and retrieves the associated `DisposeBag` for the view.
    public var disposeBag: DisposeBag {
        get {
            if let disposeBag = Self.disposeBag[self] { return disposeBag }
            let disposeBag = DisposeBag()
            Self.disposeBag[self] = disposeBag
            return disposeBag
        }
        set { Self.disposeBag[self] = newValue }
    }
}

public extension FComponent where Self: UIView, Self: Reactivable {
    /// Cancels only the named binding. Other slots and the dispose bag survive.
    func cancelRxBinding(for key: AnyHashable) {
        let subscription = rxBindingSlots.removeValue(forKey: key)
        subscription?.dispose()
    }

    /// Binds a `Driver` to the component using a provided update closure.
    ///
    /// - Parameters:
    ///   - publisher: The `Driver` that emits values to be bound.
    ///   - next: A closure that applies the emitted value to `self`.
    ///   - error: An optional closure called if an error is tracked.
    ///   - complete: An optional closure called when the stream completes.
    /// - Returns: Self for chaining.
    @discardableResult func bind<Subject>(
        to publisher: Driver<Subject>,
        next: @escaping (Self, Subject) -> Void,
        error: ((Error) -> Void)? = nil,
        complete: (() -> Void)? = nil
    ) -> Self {
        bind(to: publisher, key: nil, next: next, error: error, complete: complete)
    }

    /// Supplying a key replaces only that slot; nil retains append behavior.
    @discardableResult func bind<Subject>(
        to publisher: Driver<Subject>,
        key: AnyHashable?,
        next: @escaping (Self, Subject) -> Void,
        error: ((Error) -> Void)? = nil,
        complete: (() -> Void)? = nil
    ) -> Self {
        // Register before subscribing because Drivers may synchronously emit.
        let slot = FRxBindingSlot()
        if let key {
            cancelRxBinding(for: key)
            rxBindingSlots[key] = slot
        } else {
            slot.disposed(by: disposeBag)
        }
        let localET = ErrorTracker()
        slot.disposable = Disposables.create(
            publisher.trackError(localET).drive(onNext: { [weak self] value in
                guard let self else { return }
                next(self, value)
            }, onCompleted: { complete?() }),
            localET.drive(onNext: error)
        )
        return self
    }
}

/// Rx disposables do not automatically dispose on deinitialization.
fileprivate final class FRxBindingSlot: Disposable {
    private let serial = SerialDisposable()
    var disposable: Disposable {
        get { serial.disposable }
        set { serial.disposable = newValue }
    }
    func dispose() { serial.dispose() }
    deinit { serial.dispose() }
}
