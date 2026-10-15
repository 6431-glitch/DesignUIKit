import XCTest
import UIKit
import DesignUIKit
import RxSwift
import RxCocoa
@testable import DesignRxUIKit

@MainActor
final class FRxBindingTest: XCTestCase {
    func testKeyedReplacementAndCancellation_preserveUnrelatedBindings() {
        let old = PublishRelay<String>()
        let current = PublishRelay<String>()
        let unrelated = PublishRelay<String>()
        let label = FLabel()
        var values: [String] = []
        label.bind(to: old.asDriver(onErrorDriveWith: .empty()), key: "title") { _, value in values.append(value) }
        label.bind(to: unrelated.asDriver(onErrorDriveWith: .empty())) { _, value in values.append(value) }
        label.bind(to: current.asDriver(onErrorDriveWith: .empty()), key: "title") { _, value in values.append(value) }
        old.accept("old")
        current.accept("current")
        unrelated.accept("unrelated")
        XCTAssertEqual(values, ["current", "unrelated"])
        label.cancelRxBinding(for: "title")
        current.accept("cancelled")
        unrelated.accept("still active")
        XCTAssertEqual(values, ["current", "unrelated", "still active"])
    }

    func testViewDeallocation_disposesKeyedSubscription() {
        let source = PublishSubject<String>()
        weak var released: FLabel?
        autoreleasepool {
            let label = FLabel()
            released = label
            label.bind(to: source.asDriver(onErrorDriveWith: .empty()), key: "title") { _, _ in }
            XCTAssertTrue(source.hasObservers)
        }
        XCTAssertNil(released)
        XCTAssertFalse(source.hasObservers)
    }

    func testSynchronousInitialValue_canCancelItsOwnSlot() {
        let source = BehaviorRelay(value: "initial")
        let label = FLabel()
        var received: [String] = []
        label.bind(to: source.asDriver(), key: "title") { view, value in
            received.append(value)
            view.cancelRxBinding(for: "title")
        }
        source.accept("later")
        XCTAssertEqual(received, ["initial"])
    }

    func testKeyedStackBinding_reusesUnchangedViewsAndRejectsDuplicateIDs() {
        let source = PublishRelay<[String]>()
        let stack = FStack(axis: .vertical, arrangedContents: [])
        var invalid = 0
        var updates = 0
        stack.bindItems(to: source.asDriver(onErrorDriveWith: .empty()), key: "items", id: \.self,
            makeView: { FLabel($0) }, update: { (_: FLabel, _: String) in updates += 1 },
            onInvalidItems: { invalid += 1 })
        source.accept(["a", "b"])
        let first = stack.arrangedSubviews[0]
        source.accept(["b", "a"])
        source.accept(["a", "a"])
        XCTAssertTrue(stack.arrangedSubviews[1] === first)
        XCTAssertEqual(updates, 0)
        XCTAssertEqual(invalid, 1)
    }

    func testTypedStackErrorCallback_reportsRejectionAndRespectsCancellation() {
        let source = PublishRelay<[Int]>()
        let stack = FVStack(arrangedContents: [])
        var errors: [FStackUpdateError] = []
        stack.bindItems(to: source.asDriver(onErrorDriveWith: .empty()), key: "items", id: \.self,
            makeView: { FLabel("\($0)") }, update: { (_: FLabel, _: Int) in },
            onUpdateError: { error in
                XCTAssertTrue(Thread.isMainThread)
                errors.append(error)
            })
        source.accept([1, 2])
        let first = stack.arrangedSubviews[0]
        source.accept([1, 1])
        XCTAssertEqual(errors, [.duplicateIdentifier(firstIndex: 0, duplicateIndex: 1)])
        XCTAssertTrue(stack.arrangedSubviews[0] === first)
        stack.cancelRxBinding(for: "items")
        source.accept([2, 2])
        XCTAssertEqual(errors.count, 1)
    }

    func testBackgroundEmission_updatesUIOnMainThread() {
        let source = PublishSubject<String>()
        let label = FLabel()
        let received = expectation(description: "main thread update")
        label.bind(to: source.asDriver(onErrorDriveWith: .empty())) { view, value in
            XCTAssertTrue(Thread.isMainThread)
            view.text = value
            received.fulfill()
        }
        DispatchQueue.global().async { source.onNext("Updated") }
        wait(for: [received], timeout: 2)
        XCTAssertEqual(label.text, "Updated")
    }
}
