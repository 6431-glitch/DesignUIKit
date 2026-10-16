import XCTest
import UIKit
@testable import DesignUIKit

@MainActor
final class FSelectiveUpdateTest: XCTestCase {
    func testReload_rebuildsFViewBodyWithoutDispatchingLifecycle() {
        let parent = UIView()
        let sut = BodyView()
        parent.addSubview(sut)
        let initialMoves = sut.moveCount
        XCTAssertEqual(sut.subviews.count, 1)

        sut.reload()

        XCTAssertEqual(sut.subviews.count, 1)
        XCTAssertEqual(sut.bodyCount, 2)
        XCTAssertEqual(sut.moveCount, initialMoves)
    }

    func testAppearanceSetters_updateAttachedViewAndPreserveChildren() {
        let parent = UIView()
        let child = FLabel("Content")
        let sut = FZStack(contentViews: [child])
        parent.addSubview(sut)

        sut.alpha = 0.7
        sut.background(.red)
        XCTAssertEqual(sut.alpha, 0.7, accuracy: 0.001)
        sut.backgroundColor = .blue
        sut.opacity(0.4)

        XCTAssertEqual(sut.backgroundColor, .blue)
        XCTAssertEqual(sut.alpha, 0.4, accuracy: 0.001)
        XCTAssertTrue(sut.subviews.first === child)
    }

    func testHeightUpdate_preservesConstraintAndChildren() {
        let parent = UIView()
        let child = FLabel("Content")
        let sut = FZStack(contentViews: [child]).attachToParent(false).frame(height: 20)
        parent.addSubview(sut)
        let original = sut.constraints.first { $0.firstAttribute == .height && $0.secondItem == nil }
        XCTAssertNotNil(original)

        sut.frame(height: 40)
        sut.configuration?.applyLayout()

        let updated = sut.constraints.first { $0.firstAttribute == .height && $0.secondItem == nil }
        XCTAssertTrue(original === updated)
        XCTAssertEqual(updated?.constant, 40)
        XCTAssertTrue(sut.subviews.first === child)
    }

    func testStackReload_reconcilesInstancesWithoutReattachingUnchangedChild() {
        let parent = UIView()
        let first = BodyView()
        let removed = FLabel("Remove")
        let sut = FStack(axis: .vertical, arrangedContents: [first, removed])
        parent.addSubview(sut)
        let moves = first.moveCount
        let inserted = FLabel("Insert")
        sut.arrangedContents = [first, inserted]

        sut.reload()

        XCTAssertEqual(sut.arrangedSubviews.count, 2)
        XCTAssertTrue(sut.arrangedSubviews[0] === first)
        XCTAssertTrue(sut.arrangedSubviews[1] === inserted)
        XCTAssertNil(removed.superview)
        XCTAssertEqual(first.moveCount, moves)
    }

    func testScrollReload_updatesOwnedContentWithoutRemovingUnchangedViews() {
        let parent = UIView()
        let first = BodyView()
        let removed = FLabel("Remove")
        let sut = FScroll(axis: .vertical) { first; removed }
        parent.addSubview(sut)
        let moves = first.moveCount
        let inserted = FLabel("Insert")
        sut.contentViews = [first, inserted]

        sut.reload()

        XCTAssertTrue(first.superview === sut)
        XCTAssertTrue(inserted.superview === sut)
        XCTAssertNil(removed.superview)
        XCTAssertEqual(first.moveCount, moves)
    }

    func testLeafReload_keepsUIKitInternalSubviews() {
        let parent = UIView()
        let sut = FLabel("Title")
        let accessory = UIView()
        parent.addSubview(sut)
        sut.addSubview(accessory)

        sut.reload()

        XCTAssertTrue(accessory.superview === sut)
        XCTAssertEqual(sut.text, "Title")
    }
}

@MainActor
private final class BodyView: FView {
    var bodyCount = 0
    var moveCount = 0

    override var body: FBodyComponent {
        bodyCount += 1
        return FLabel("Body \(bodyCount)")
    }

    override func didMoveToSuperview() {
        moveCount += 1
        super.didMoveToSuperview()
    }
}
