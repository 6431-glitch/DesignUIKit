import XCTest
import UIKit
@testable import DesignUIKit

@MainActor
final class FConfigurationTest: XCTestCase {
    func testReparenting_restoresBuiltInInheritedStylesAndRetainsLocalModifiers() {
        let first = FZStack().modified(with: FForegroundModifier(color: .red))
        let second = FZStack()
        let label = FLabel("Title").foreground(.green)
            .modified(with: FFontModifier(font: .boldSystemFont(ofSize: 19)))
        first.addSubview(label)
        XCTAssertEqual(label.textColor, .red)
        for _ in 0..<3 {
            label.removeFromSuperview()
            first.addSubview(label)
        }
        XCTAssertEqual(label.configuration?.modifiers.count, 1)

        second.addSubview(label)

        XCTAssertEqual(label.textColor, .green)
        XCTAssertEqual(label.font, .boldSystemFont(ofSize: 19))
        XCTAssertEqual(label.configuration?.effectiveModifiers.count, 1)
    }

    func testInheritedAppearance_doesNotOverwriteLaterDirectChangeOnRemoval() {
        let parent = FZStack().modified(with: FBackgroundModifier(color: .red))
        let child = FLabel("Title").background(.green)
        parent.addSubview(child)
        XCTAssertEqual(child.backgroundColor, .red)
        child.background(.blue)

        child.removeFromSuperview()

        XCTAssertEqual(child.backgroundColor, .blue)
    }

    func testLayoutUpdate_preservesConsumerConstraintAndUnchangedOwnedConstraint() {
        let parent = UIView()
        let sut = FLabel("Title").attachToParent(false).frame(width: 80, height: 20)
        parent.addSubview(sut)
        let width = sut.constraints.first { $0.identifier == "FastView.width" }
        let consumer = sut.centerXAnchor.constraint(equalTo: parent.centerXAnchor)
        consumer.isActive = true
        sut.frame(height: 50)
        sut.configuration?.applyLayout()

        XCTAssertTrue(width === sut.constraints.first { $0.identifier == "FastView.width" })
        XCTAssertTrue(consumer.isActive)
        XCTAssertEqual(sut.constraints.filter { $0.identifier == "FastView.height" }.count, 1)
    }

    func testRepeatedLayoutFlush_doesNotReinstallCustomConstraints() {
        let parent = UIView()
        var applications = 0
        let sut = FLabel("Title").attachToParent(false).layout { make, _ in
            applications += 1
            make.height.equalTo(30)
        }
        parent.addSubview(sut)
        for _ in 0..<3 {
            sut.configuration?.invalidateLayout()
            sut.configuration?.applyLayout()
        }
        XCTAssertEqual(applications, 1)
        XCTAssertEqual(sut.constraints.filter { $0.firstAttribute == .height }.count, 1)
    }

    func testLayoutChanges_areCoalescedUntilFlush() {
        let parent = UIView()
        let sut = FLabel("Title").attachToParent(false).frame(height: 10)
        parent.addSubview(sut)
        let height = sut.constraints.first { $0.identifier == "FastView.height" }
        sut.frame(height: 20).frame(height: 30).frame(height: 40)
        XCTAssertEqual(height?.constant, 10)
        sut.configuration?.applyLayout()
        XCTAssertEqual(height?.constant, 40)
    }

    func testShapeChange_resetsCornerMaskAndCanClearShape() {
        let parent = UIView()
        let sut = FZStack().shaped(.roundedRectangle(cornerRadius: 10, corners: .topLeft))
        parent.addSubview(sut)
        sut.bounds.size = .init(width: 100, height: 100)
        sut.configuration?.updateLayers(for: sut)
        sut.shaped(.circle)
        sut.configuration?.updateLayers(for: sut)
        XCTAssertEqual(sut.layer.maskedCorners.rawValue, 15)
        sut.configuration?.shape = nil
        sut.configuration?.updateLayers(for: sut)
        XCTAssertEqual(sut.layer.cornerRadius, 0)
    }

    func testReload_doesNotReplaceViewWithModifierReturnValue() {
        let parent = UIView()
        let original = FLabel("Original").modified(with: ReplacementModifier())
        parent.addSubview(original)
        original.reload()
        XCTAssertTrue(original.superview === parent)
        XCTAssertEqual(parent.subviews.count, 1)
        XCTAssertEqual(original.text, "Original")
    }
}

@MainActor
private struct ReplacementModifier: FModifier {
    func body(_ content: FBodyComponent) -> FBodyComponent { FLabel("Replacement") }
}
