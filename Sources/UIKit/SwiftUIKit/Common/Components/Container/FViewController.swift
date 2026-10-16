//
//  FViewController.swift
//  DesignUIKit
//
//  Created by Duke Nguyen on 2024/02/23.
//
//  A component for embedding a child UIViewController inside a UIView,
//  and a hosting container controller that can wrap any `FView` structure.
//

import UIKit
import SnapKit
import DesignCore
import DesignExts
import Foundation

/// A wrapper component that embeds a view controller's view into a parent view hierarchy,
/// handling view controller containment and layout.
@MainActor public final class FViewController: BaseView, FComponent {
    /// Optional closure for applying additional runtime configuration.
    public var customConfiguration: ((FViewController) -> Void)?
    
    /// The parent view controller that will host the embedded child view controller.
    public weak var parentViewController: UIViewController?
    /// The embedded content view controller to display inside this view.
    public var contentViewController: UIViewController
    
    /// Initializes the component with a content view controller.
    /// - Parameter contentViewController: The child view controller to embed.
    public init(_ contentViewController: UIViewController) {
        self.contentViewController = contentViewController
        super.init(frame: .zero)
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configuration?.didMoveToSuperview(superview, with: self)
        guard superview != nil else { return }
        attachContentViewControllerIfNeeded()
        customConfiguration?(self)
    }

    public func updateContent() {
        guard superview != nil else { return }
        attachContentViewControllerIfNeeded()
    }

    public override func removeFromSuperview() {
        parentViewController = nil
        detachContentViewController()
        super.removeFromSuperview()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        configuration?.updateLayers(for: self)
    }
    
    /// Assigns the parent view controller to host the content controller.
    /// - Parameter viewController: The parent view controller.
    /// - Returns: Self for fluent chaining.
    @discardableResult public func parent(_ viewController: UIViewController) -> Self {
        guard parentViewController !== viewController else { return self }
        parentViewController = viewController
        if superview != nil {
            attachContentViewControllerIfNeeded()
        }
        return self
    }

    deinit {
        logger.trace("Deinitialized \(self)")
    }
}

private extension FViewController {
    func attachContentViewControllerIfNeeded() {
        guard let parentViewController else { return }

        if contentViewController.parent !== nil, contentViewController.parent !== parentViewController {
            detachContentViewController()
        }

        let shouldNotifyDidMove = contentViewController.parent !== parentViewController
        if contentViewController.parent !== parentViewController {
            parentViewController.addChild(contentViewController)
        }
        if contentViewController.view.superview !== self {
            addSubview(contentViewController.view)
        }
        contentViewController.view.snp.remakeConstraints { $0.edges.equalToSuperview() }
        if shouldNotifyDidMove, contentViewController.parent === parentViewController {
            contentViewController.didMove(toParent: parentViewController)
        }
    }

    func detachContentViewController() {
        guard contentViewController.parent != nil else {
            contentViewController.view.removeFromSuperview()
            return
        }
        contentViewController.willMove(toParent: nil)
        contentViewController.view.removeFromSuperview()
        contentViewController.removeFromParent()
    }
}

/// A hosting view controller that wraps and displays a stack of body components as a single view.
@MainActor public class FViewContainer: UIViewController, Chainable, Loggable {
    /// The root view constructed from FBody content.
    public var content: UIView
    
    /// Closure triggered when the corresponding lifecycle event occurs.
    var onLoad: ((FViewContainer) -> Void)?
    /// Closure triggered when the corresponding lifecycle event occurs.
    var onAppear: ((FViewContainer) -> Void)?
    /// Closure triggered when the corresponding lifecycle event occurs.
    var onDisappear: ((FViewContainer) -> Void)?

    public convenience init(@FViewBuilder _ content: () -> FBody) {
        self.init(content())
    }
    
    /// Initializes the container with a built body view.
    /// - Parameter content: The FBody component to display.
    public init(_ content: FBody) {
        self.content = FZStack(contentViews: content).ignoreSafeArea(true)
        super.init(nibName: nil, bundle: .main)
    }

    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    public required init?(coder: NSCoder) { fatalError("Unimplemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(content)
        onLoad?(self)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onAppear?(self)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDisappear?(self)
    }

    deinit {
        logger.trace("Deinitialized \(self)")
    }
}

public extension FViewContainer {
    /// Sets a closure to be invoked on the corresponding lifecycle event.
    /// - Parameter action: The closure to execute.
    /// - Returns: Self for chaining.
    func onLoad(_ action: @escaping (FViewContainer) -> Void) -> Self {
        onLoad = action
        return self
    }
    
    /// Sets a closure to be invoked on the corresponding lifecycle event.
    /// - Parameter action: The closure to execute.
    /// - Returns: Self for chaining.
    func onAppear(_ action: @escaping (FViewContainer) -> Void) -> Self {
        onAppear = action
        return self
    }
    
    /// Sets a closure to be invoked on the corresponding lifecycle event.
    /// - Parameter action: The closure to execute.
    /// - Returns: Self for chaining.
    func onDisappear(_ action: @escaping (FViewContainer) -> Void) -> Self {
        onDisappear = action
        return self
    }
}
