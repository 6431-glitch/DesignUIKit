import XCTest
import UIKit
@testable import DesignUIKit

@MainActor
final class FViewControllerTest: XCTestCase {
    func testAttach_whenAddedToSuperview_invokesContainmentLifecycleOnce() {
        let parent = UIViewController()
        _ = parent.view
        let child = SpyChildViewController()
        let sut = FViewController(child).parent(parent)

        let container = UIView(frame: .init(x: 0, y: 0, width: 200, height: 200))
        parent.view.addSubview(container)
        container.addSubview(sut)

        XCTAssertEqual(parent.children.count, 1)
        XCTAssertTrue(parent.children.first === child)
        XCTAssertEqual(child.willMoveToParentCount(parent), 1)
        XCTAssertEqual(child.didMoveToParentCount(parent), 1)
    }

    func testAttach_whenDidMoveToSuperviewCalledAgain_doesNotReaddChild() {
        let parent = UIViewController()
        _ = parent.view
        let child = SpyChildViewController()
        let sut = FViewController(child).parent(parent)

        let container = UIView(frame: .init(x: 0, y: 0, width: 200, height: 200))
        parent.view.addSubview(container)
        container.addSubview(sut)
        sut.didMoveToSuperview()

        XCTAssertEqual(parent.children.count, 1)
        XCTAssertEqual(child.willMoveToParentCount(parent), 1)
        XCTAssertEqual(child.didMoveToParentCount(parent), 1)
    }

    func testReload_preservesContainmentAndChildView() {
        let parent = UIViewController()
        let child = SpyChildViewController()
        let sut = FViewController(child).parent(parent)
        parent.view.addSubview(sut)
        let originalView = child.view

        sut.reload()

        XCTAssertTrue(child.parent === parent)
        XCTAssertTrue(child.view === originalView)
        XCTAssertTrue(child.view.superview === sut)
        XCTAssertEqual(child.willMoveToParentCount(parent), 1)
        XCTAssertEqual(child.didMoveToParentCount(parent), 1)
    }

}

private final class SpyChildViewController: UIViewController {
    private(set) var willMoveParents: [UIViewController?] = []
    private(set) var didMoveParents: [UIViewController?] = []

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        willMoveParents.append(parent)
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        didMoveParents.append(parent)
    }

    func willMoveToParentCount(_ parent: UIViewController) -> Int {
        willMoveParents.filter { $0 === parent }.count
    }

    func didMoveToParentCount(_ parent: UIViewController) -> Int {
        didMoveParents.filter { $0 === parent }.count
    }
}
