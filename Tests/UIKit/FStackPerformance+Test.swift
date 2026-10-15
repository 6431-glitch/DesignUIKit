import XCTest
import UIKit
@testable import DesignUIKit

@MainActor
final class FStackPerformanceTest: XCTestCase {
    struct Item: Equatable {
        let id: Int
        var title: String
    }

    /// Compares the existing render-all strategy against keyed updates on the
    /// same implementation. Latency is diagnostic, not a flaky pass/fail threshold.
    func testKeyedWorkloads_allocateOnlyInsertedViews() {
        let items = (0..<100).map { Item(id: $0, title: "Row \($0)") }
        let baseline = FStack(axis: .vertical, arrangedContents: [])
        let keyed = FStack(axis: .vertical, arrangedContents: [])
        var baselineCreated = 0
        var keyedCreated = 0
        var updated = 0
        func renderAll(_ rows: [Item]) {
            baseline.arrangedContents = rows.map { item in
                baselineCreated += 1
                return FLabel(item.title)
            }
            baseline.reload()
        }
        func renderKeyed(_ rows: [Item]) {
            XCTAssertTrue(keyed.updateItems(rows, id: \.id, makeView: { item -> FLabel in
                keyedCreated += 1
                return FLabel(item.title)
            }, update: { label, item in
                updated += 1
                label.text = item.title
            }))
        }
        renderAll(items)
        renderKeyed(items)
        baselineCreated = 0
        keyedCreated = 0
        let baselineChange = elapsed {
            for iteration in 0..<10 {
                var changed = items
                changed[50].title = "Changed \(iteration)"
                renderAll(changed)
            }
        }
        let keyedChange = elapsed {
            for iteration in 0..<10 {
                var changed = items
                changed[50].title = "Changed \(iteration)"
                renderKeyed(changed)
            }
        }
        XCTAssertEqual(baselineCreated, 1000)
        XCTAssertEqual(keyedCreated, 0)
        XCTAssertEqual(updated, 10)
        print("FastView benchmark: 100 rows, 10 one-item changes; render-all created=\(baselineCreated) ms=\(baselineChange); keyed created=\(keyedCreated) updated=\(updated) ms=\(keyedChange)")

        // Reset both to identical snapshots before the reorder-only measurement.
        renderAll(items)
        renderKeyed(items)
        baselineCreated = 0
        keyedCreated = 0
        updated = 0
        let baselineReorder = elapsed {
            for iteration in 0..<10 { renderAll(iteration.isMultiple(of: 2) ? items.reversed() : items) }
        }
        let keyedReorder = elapsed {
            for iteration in 0..<10 { renderKeyed(iteration.isMultiple(of: 2) ? items.reversed() : items) }
        }
        XCTAssertEqual(baselineCreated, 1000)
        XCTAssertEqual(keyedCreated, 0)
        XCTAssertEqual(updated, 0)
        print("FastView benchmark: 100 rows, 10 reorders; render-all created=\(baselineCreated) ms=\(baselineReorder); keyed created=\(keyedCreated) updated=\(updated) ms=\(keyedReorder)")

        let retained = keyed.arrangedSubviews.map { ObjectIdentifier($0) }
        let propertyChange = elapsed {
            for iteration in 0..<100 {
                (keyed.arrangedSubviews[50] as? FLabel)?.text = "Local \(iteration)"
            }
        }
        XCTAssertEqual(keyed.arrangedSubviews.map { ObjectIdentifier($0) }, retained)
        XCTAssertEqual(keyedCreated, 0)
        print("FastView benchmark: 100 property updates; created=0 ms=\(propertyChange)")
    }

    private func elapsed(_ work: () -> Void) -> Double {
        let start = Date.timeIntervalSinceReferenceDate
        work()
        return (Date.timeIntervalSinceReferenceDate - start) * 1000
    }
}
