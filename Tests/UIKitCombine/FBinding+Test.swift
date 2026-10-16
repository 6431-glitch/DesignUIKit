import XCTest
import UIKit
import Combine
import DesignUIKit
@testable import DesignCombineUIKit

@MainActor
final class FCombineBindingTest: XCTestCase {
    func testKeyedReplacementAndCancellation_preserveUnrelatedBindings() {
        let old = PassthroughSubject<String, Never>()
        let current = PassthroughSubject<String, Never>()
        let unrelated = PassthroughSubject<String, Never>()
        let label = FLabel()
        var values: [String] = []
        var cancelled = 0
        label.bind(to: old.handleEvents(receiveCancel: { cancelled += 1 }).eraseToAnyPublisher(), key: "title") { _, value in values.append(value) }
        label.bind(to: unrelated.eraseToAnyPublisher()) { _, value in values.append(value) }
        label.bind(to: current.eraseToAnyPublisher(), key: "title") { _, value in values.append(value) }
        XCTAssertEqual(cancelled, 1)
        old.send("old")
        current.send("current")
        unrelated.send("unrelated")
        drainMainQueue()
        XCTAssertEqual(values, ["current", "unrelated"])

        label.cancelCombineBinding(for: "title")
        current.send("cancelled")
        unrelated.send("still active")
        drainMainQueue()
        XCTAssertEqual(values, ["current", "unrelated", "still active"])
    }

    func testViewDeallocation_cancelsKeyedSubscription() {
        let source = PassthroughSubject<String, Never>()
        var cancellations = 0
        weak var released: FLabel?
        autoreleasepool {
            let label = FLabel()
            released = label
            label.bind(to: source.handleEvents(receiveCancel: { cancellations += 1 }).eraseToAnyPublisher(), key: "title") { _, _ in }
        }
        XCTAssertNil(released)
        XCTAssertEqual(cancellations, 1)
    }

    func testBackgroundEmission_updatesUIOnMainThread() {
        let source = PassthroughSubject<String, Never>()
        let label = FLabel()
        let received = expectation(description: "main thread update")
        label.bind(to: source.eraseToAnyPublisher()) { view, value in
            XCTAssertTrue(Thread.isMainThread)
            view.text = value
            received.fulfill()
        }
        DispatchQueue.global().async { source.send("Updated") }
        wait(for: [received], timeout: 2)
        XCTAssertEqual(label.text, "Updated")
    }

    func testKeyedStackBinding_reusesUnchangedViewsAndRejectsDuplicateIDs() {
        let source = PassthroughSubject<[String], Never>()
        let stack = FStack(axis: .vertical, arrangedContents: [])
        var invalid = 0
        var updates = 0
        stack.bindItems(to: source.eraseToAnyPublisher(), key: "items", id: \.self,
            makeView: { FLabel($0) }, update: { (_: FLabel, _: String) in updates += 1 },
            onInvalidItems: { invalid += 1 })
        source.send(["a", "b"])
        drainMainQueue()
        let first = stack.arrangedSubviews[0]
        source.send(["b", "a"])
        source.send(["a", "a"])
        drainMainQueue()
        XCTAssertTrue(stack.arrangedSubviews[1] === first)
        XCTAssertEqual(updates, 0)
        XCTAssertEqual(invalid, 1)
    }

    func testTypedStackErrorCallback_reportsRejectionAndRespectsCancellation() {
        let source = PassthroughSubject<[Int], Never>()
        let stack = FVStack(arrangedContents: [])
        var errors: [FStackUpdateError] = []
        stack.bindItems(to: source.eraseToAnyPublisher(), key: "items", id: \.self,
            makeView: { FLabel("\($0)") }, update: { (_: FLabel, _: Int) in },
            onUpdateError: { error in
                XCTAssertTrue(Thread.isMainThread)
                errors.append(error)
            })
        source.send([1, 2])
        drainMainQueue()
        let first = stack.arrangedSubviews[0]
        source.send([1, 1])
        drainMainQueue()
        XCTAssertEqual(errors, [.duplicateIdentifier(firstIndex: 0, duplicateIndex: 1)])
        XCTAssertTrue(stack.arrangedSubviews[0] === first)
        stack.cancelCombineBinding(for: "items")
        source.send([2, 2])
        drainMainQueue()
        XCTAssertEqual(errors.count, 1)
    }

    private func drainMainQueue() {
        let drained = expectation(description: "main queue drained")
        DispatchQueue.main.async { drained.fulfill() }
        wait(for: [drained], timeout: 2)
    }
}
