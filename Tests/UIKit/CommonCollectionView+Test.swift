import XCTest
import UIKit
@testable import DesignUIKit

@MainActor
final class CommonCollectionViewTest: XCTestCase {
    func testReloadData_whenCalledRepeatedlyWithChangingSectionCounts_keepsStateConsistent() {
        let sut = makeSUT()
        let host = UIView(frame: .init(x: 0, y: 0, width: 320, height: 480))
        host.addSubview(sut)
        sut.frame = host.bounds

        for index in 0 ..< 40 {
            let sectionCount = index.isMultiple(of: 2) ? 3 : 1
            let sections = (0 ..< sectionCount).map { sectionIndex in
                makeSection(cells: [CellModel(identifier: "\(index)-\(sectionIndex)")])
            }
            sut.reloadData(sections: sections)
            sut.layoutIfNeeded()
        }

        XCTAssertEqual(sut.numberOfSections, 1)
        XCTAssertEqual(sut.numberOfItems(inSection: 0), 1)
    }

    func testReloadData_whenCalledOffMainThread_dispatchesSafelyToMainThread() {
        let sut = makeSUT()
        let expectation = expectation(description: "reloadData")

        DispatchQueue.global(qos: .userInitiated).async {
            sut.reloadData(sections: [self.makeSection(cells: [CellModel(identifier: "bg")])])
            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.numberOfSections, 1)
        XCTAssertEqual(sut.numberOfItems(inSection: 0), 1)
    }

    func testDidSelectItemAt_whenIndexPathIsOutOfRange_ignoresSelection() {
        let sut = makeSUT()
        let delegate = SpyCollectionDelegate()
        sut.commonDelegate = delegate
        sut.reloadData(sections: [makeSection(cells: [CellModel(identifier: "0")])])

        sut.collectionView(sut, didSelectItemAt: .init(item: 99, section: 0))
        sut.collectionView(sut, didSelectItemAt: .init(item: 0, section: 99))

        XCTAssertTrue(delegate.selectedIDs.isEmpty)
    }

    func testDidSelectItemAt_whenIndexPathIsValid_notifiesDelegate() {
        let sut = makeSUT()
        let delegate = SpyCollectionDelegate()
        sut.commonDelegate = delegate
        sut.reloadData(sections: [makeSection(cells: [CellModel(identifier: "selected")])])

        sut.collectionView(sut, didSelectItemAt: .init(item: 0, section: 0))

        XCTAssertEqual(delegate.selectedIDs, ["selected"])
    }
}

private extension CommonCollectionViewTest {
    func makeSUT() -> CommonCollection.View {
        .init(itemMapper: [CellModel.self], sectionMapper: [])
    }

    func makeSection(cells: [CommonCollectionCellModel]) -> CommonCollection.Section {
        .init(cells: cells, layoutStyle: .customized { _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(44)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: itemSize,
                subitems: [item]
            )
            return NSCollectionLayoutSection(group: group)
        })
    }
}

private final class SpyCollectionDelegate: NSObject, CommonCollectionViewDelegate {
    private(set) var selectedIDs: [String] = []

    @objc func didSelectCell(at indexPath: IndexPath, with data: CommonCollectionCellModel) {
        selectedIDs.append(data.identifier)
    }
}

private final class CellModel: NSObject, CommonCollectionCellModel {
    let identifier: String
    let customConfiguration: (@Sendable (CommonCollection.CollectionCell) -> Void)? = nil
    let selectable: Bool = true
    var realData: Sendable? { identifier }

    init(identifier: String) {
        self.identifier = identifier
    }

    static var cellKind: CommonCollection.CollectionCell.Type { TestCell.self }
}

private final class TestCell: CommonCollection.CollectionCell {
    override func bind(_ model: CommonCollectionCellModel) {
        identifier = model.identifier
    }
}
