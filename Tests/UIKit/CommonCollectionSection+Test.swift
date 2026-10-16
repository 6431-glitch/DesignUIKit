import XCTest
import UIKit
@testable import DesignUIKit

@MainActor
final class CommonCollectionSectionTest: XCTestCase {
    func testPreconfiguredLayout_preservesSpacingInsetsAndPaging() {
        let dimension = CommonCollection.Section.LayoutDimension(
            itemSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)),
            itemSpacing: 4,
            groupSize: .init(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(120)),
            groupSpacing: 16,
            numberItemsPerGroup: 3,
            sectionInset: .init(top: 2, left: 3, bottom: 5, right: 7),
            pagingBehaviour: .groupPaging
        )
        let sut = CommonCollection.Section(cells: makeCells(count: 99), layoutStyle: .preconfigured(dimension))

        let layout = sut.layout()

        XCTAssertEqual(layout.interGroupSpacing, 16)
        XCTAssertEqual(layout.contentInsets, .init(top: 2, leading: 3, bottom: 5, trailing: 7))
        XCTAssertEqual(layout.orthogonalScrollingBehavior, .groupPaging)
    }

    func testCustomizedLayout_receivesCurrentSection() {
        var received: CommonCollection.Section?
        let expected = NSCollectionLayoutSection(group: .horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80)),
            subitems: [NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))) ]
        ))
        let sut = CommonCollection.Section(cells: makeCells(count: 2), layoutStyle: .customized { section in
            received = section
            return expected
        })

        XCTAssertTrue(sut.layout() === expected)
        XCTAssertTrue(received === sut)
        XCTAssertEqual(received?.cells.count, 2)
    }

}

private extension CommonCollectionSectionTest {
    func makeCells(count: Int) -> [CommonCollectionCellModel] {
        (0..<count).map { TestCollectionCellModel(identifier: "item-\($0)") }
    }
}

private final class TestCollectionCellModel: NSObject, CommonCollectionCellModel {
    let identifier: String
    let selectable: Bool = true
    let customConfiguration: (@Sendable (CommonCollection.CollectionCell) -> Void)? = nil
    var realData: Sendable? { identifier }

    init(identifier: String) {
        self.identifier = identifier
    }

    static var cellKind: CommonCollection.CollectionCell.Type { TestCollectionCell.self }
}

private final class TestCollectionCell: CommonCollection.CollectionCell {
    override func bind(_ model: CommonCollectionCellModel) {
        identifier = model.identifier
    }
}
