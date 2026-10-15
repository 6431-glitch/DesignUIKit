import XCTest
import UIKit
@testable import DesignUIKit

@MainActor
final class FStackItemsTest: XCTestCase {
    struct Item: Equatable {
        let id: Int
        var title: String
    }

    func testKeyedUpdates_createAndUpdateOnlyAffectedItems() {
        let stack = FStack(axis: .vertical, arrangedContents: [])
        var creations = 0
        var updates: [Int] = []
        func render(_ items: [Item]) {
            XCTAssertTrue(stack.updateItems(items, id: \.id, makeView: { item -> FLabel in
                creations += 1
                return FLabel(item.title)
            }, update: { view, item in
                updates.append(item.id)
                view.text = item.title
            }))
        }
        render([.init(id: 1, title: "A"), .init(id: 2, title: "B")])
        let original = stack.arrangedSubviews
        render([.init(id: 1, title: "A"), .init(id: 2, title: "Changed")])
        XCTAssertEqual(creations, 2)
        XCTAssertEqual(updates, [2])
        XCTAssertTrue(stack.arrangedSubviews[0] === original[0])
        XCTAssertTrue(stack.arrangedSubviews[1] === original[1])
        render([.init(id: 2, title: "Changed"), .init(id: 3, title: "C")])
        XCTAssertEqual(creations, 3)
        XCTAssertEqual(updates, [2])
        XCTAssertNil(original[0].superview)
        XCTAssertTrue(stack.arrangedSubviews[0] === original[1])
    }

    func testDuplicateIDs_rejectsBeforeCallingClientClosuresOrChangingViews() {
        let stack = FStack(axis: .vertical, arrangedContents: [])
        stack.updateItems([Item(id: 1, title: "A")], id: \.id, makeView: { FLabel($0.title) }, update: { _, _ in })
        let original = stack.arrangedSubviews[0]
        let accepted = stack.updateItems([Item(id: 1, title: "B"), .init(id: 1, title: "C")], id: \.id,
            makeView: { _ -> FLabel in XCTFail("Must validate IDs before creation"); return FLabel() },
            update: { _, _ in XCTFail("Must validate IDs before updates") })
        XCTAssertFalse(accepted)
        XCTAssertTrue(stack.arrangedSubviews[0] === original)
        XCTAssertEqual((original as? FLabel)?.text, "A")
    }

    func testManualContentAssignment_discardsKeyedHistory() {
        let stack = FStack(axis: .vertical, arrangedContents: [])
        let item = Item(id: 1, title: "A")
        stack.updateItems([item], id: \.id, makeView: { FLabel($0.title) }, update: { _, _ in })
        let original = stack.arrangedSubviews[0]
        stack.arrangedContents = [FLabel("Manual")]
        stack.reload()
        var creations = 0

        stack.updateItems([item], id: \.id, makeView: { item -> FLabel in
            creations += 1
            return FLabel(item.title)
        }, update: { _, _ in XCTFail("Manual reset must discard the old snapshot") })

        XCTAssertEqual(creations, 1)
        XCTAssertFalse(stack.arrangedSubviews[0] === original)
    }

    func testReusedViewForDifferentIDs_rejectsBeforeUpdatingRetainedView() {
        let stack = FStack(axis: .vertical, arrangedContents: [])
        stack.updateItems([Item(id: 1, title: "A")], id: \.id, makeView: { FLabel($0.title) }, update: { _, _ in })
        let original = stack.arrangedSubviews[0] as! FLabel
        let accepted = stack.updateItems([Item(id: 1, title: "Changed"), .init(id: 2, title: "B")], id: \.id,
            makeView: { _ in original }, update: { _, _ in XCTFail("Invalid view reuse must not apply changes") })
        XCTAssertFalse(accepted)
        XCTAssertEqual(original.text, "A")
        XCTAssertEqual(stack.arrangedSubviews.count, 1)
    }

    func testChangedModelType_reusesCompatibleViewAndUpdatesItsContent() {
        struct AlternateItem: Equatable { let id: Int; let value: String }
        let stack = FStack(axis: .vertical, arrangedContents: [])
        stack.updateItems([Item(id: 1, title: "A")], id: \.id, makeView: { FLabel($0.title) }, update: { _, _ in })
        let original = stack.arrangedSubviews[0]

        stack.updateItems([AlternateItem(id: 1, value: "B")], id: \.id,
            makeView: { FLabel($0.value) }, update: { (view: FLabel, item: AlternateItem) in view.text = item.value })

        XCTAssertTrue(stack.arrangedSubviews[0] === original)
        XCTAssertEqual((original as? FLabel)?.text, "B")
    }

    func testReorder_preservesFirstResponderAndTextSelection() throws {
        #if targetEnvironment(macCatalyst)
        // A package test process has no application lifecycle for native windows.
        guard UIApplication.shared.delegate != nil else {
            throw XCTSkip("Run the CatalystHost scheme for window and first-responder coverage.")
        }
        #endif
        let window = UIWindow(frame: .init(x: 0, y: 0, width: 320, height: 480))
        let controller = UIViewController()
        window.rootViewController = controller
        let stack = FStack(axis: .vertical, arrangedContents: [])
        controller.view.addSubview(stack)
        let first = Item(id: 1, title: "Editable")
        let second = Item(id: 2, title: "Other")
        stack.updateItems([first, second], id: \.id, makeView: { FTextField("", $0.title) }, update: { _, _ in })
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        let field = stack.arrangedSubviews[0] as! FTextField
        XCTAssertTrue(field.becomeFirstResponder())
        field.text = "Local edit"
        let start = field.position(from: field.beginningOfDocument, offset: 2)!
        field.selectedTextRange = field.textRange(from: start, to: start)

        stack.updateItems([second, first], id: \.id, makeView: { FTextField("", $0.title) }, update: { _, _ in })

        XCTAssertTrue(stack.arrangedSubviews[1] === field)
        XCTAssertTrue(field.isFirstResponder)
        XCTAssertEqual(field.text, "Local edit")
        XCTAssertEqual(field.offset(from: field.beginningOfDocument, to: field.selectedTextRange!.start), 2)
    }

    func testRemovedItems_areReleasedByKeyedStorage() {
        let stack = FStack(axis: .vertical, arrangedContents: [])
        weak var removed: FLabel?
        autoreleasepool {
            stack.updateItems([Item(id: 1, title: "A")], id: \.id, makeView: { item -> FLabel in
                let label = FLabel(item.title)
                removed = label
                return label
            }, update: { _, _ in })
            XCTAssertNotNil(removed)
            stack.updateItems([Item](), id: \.id, makeView: { FLabel($0.title) }, update: { _, _ in })
            stack.layoutIfNeeded()
        }
        XCTAssertNil(removed)
        XCTAssertTrue(stack.arrangedSubviews.isEmpty)
    }
}
