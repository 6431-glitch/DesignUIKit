import XCTest
import UIKit
@testable import DesignUIKit

@MainActor
final class FUsabilityDiagnosticsTest: XCTestCase {
    func testDuplicateIDResult_reportsPositionsBeforeRendering() {
        let stack = FVStack(arrangedContents: [])
        let result = stack.updateItemsResult([1, 2, 1], id: \.self,
            makeView: { _ -> FLabel in XCTFail("Must validate IDs first"); return FLabel() },
            update: { _, _ in XCTFail("Invalid input must not update views") })
        guard case let .failure(error) = result else { return XCTFail("Expected rejection") }
        XCTAssertEqual(error, .duplicateIdentifier(firstIndex: 0, duplicateIndex: 2))
        XCTAssertTrue(error.localizedDescription.contains("unique, stable ID"))
        XCTAssertTrue(stack.arrangedSubviews.isEmpty)
    }

    func testReusedViewResult_preservesInstalledContent() {
        let stack = FVStack(arrangedContents: [])
        stack.updateItems([1], id: \.self, makeView: { FLabel("\($0)") }, update: { _, _ in })
        let original = stack.arrangedSubviews[0] as! FLabel
        let result = stack.updateItemsResult([1, 2], id: \.self,
            makeView: { _ in original }, update: { _, _ in XCTFail("Must reject before retained updates") })
        guard case let .failure(error) = result else { return XCTFail("Expected rejection") }
        XCTAssertEqual(error, .reusedView(firstIndex: 0, duplicateIndex: 1))
        XCTAssertTrue(error.localizedDescription.contains("distinct view from makeView"))
        XCTAssertTrue(stack.arrangedSubviews[0] === original)
        XCTAssertEqual(stack.arrangedSubviews.count, 1)
        XCTAssertEqual(original.text, "1")
    }

    func testCustomEqualityResult_updatesRetainedView() {
        struct Row { let id: Int; let title: String }
        let stack = FVStack(arrangedContents: [])
        func render(_ row: Row) -> Result<Void, FStackUpdateError> {
            stack.updateItemsResult([row], id: \.id, areEquivalent: { $0.title == $1.title },
                makeView: { FLabel($0.title) }, update: { (label: FLabel, row: Row) in label.text = row.title })
        }
        guard case .success = render(Row(id: 1, title: "A")) else { return XCTFail("Expected success") }
        let original = stack.arrangedSubviews[0]
        guard case .success = render(Row(id: 1, title: "B")) else { return XCTFail("Expected success") }
        XCTAssertTrue(stack.arrangedSubviews[0] === original)
        XCTAssertEqual((original as? FLabel)?.text, "B")
    }

    func testPinnedDimensionDiagnostics_clearWhenEdgesAreReleased() {
        let label = FLabel("Title").frame(width: 80, height: 20)
        XCTAssertEqual(label.layoutDiagnostics(), [.fixedWidthWithPinnedEdges, .fixedHeightWithPinnedEdges])
        label.ignore(edges: [.trailing, .bottom])
        XCTAssertTrue(label.layoutDiagnostics().isEmpty)
    }

    func testCustomAndStackManagedLayout_doesNotReportAutomaticParentPins() {
        let label = FLabel("Title").frame(width: 80, height: 20).attachToParent(false)
        XCTAssertTrue(label.layoutDiagnostics().isEmpty)
        let arranged = FLabel("Arranged").frame(height: 20)
        let stack = FVStack { arranged }
        stack.updateContent()
        XCTAssertTrue(arranged.layoutDiagnostics().isEmpty)
    }

    func testDiagnosticInspection_doesNotFlushLayoutAndIgnoresCenteredDimensions() {
        let label = FLabel("Title").frame(width: 80, height: 20)
        XCTAssertTrue(label.configuration?.needsLayoutUpdate ?? false)
        _ = label.layoutDiagnostics()
        XCTAssertTrue(label.configuration?.needsLayoutUpdate ?? false)
        XCTAssertTrue(label.constraints.isEmpty)
        label.centerInParent()
        XCTAssertTrue(label.layoutDiagnostics().isEmpty)
    }
}
