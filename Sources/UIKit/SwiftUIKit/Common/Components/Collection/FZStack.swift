//
//  FZStack.swift
//  DesignUIKit
//
//  Created by Duke Nguyen on 2024/02/11.
//
//  A flexible vertical stack component that composes multiple body components into a single layout.
//  Supports configuration via fluent APIs and optional content flattening.
//

import UIKit
import DesignCore

/// A flexible vertical stack component that wraps and lays out multiple body components.
/// Automatically flattens `FForEach` containers for simpler layout.
public final class FZStack: BaseView, FComponent {
    /// Optional closure for applying additional runtime customization after setup.
    public var customConfiguration: ((FZStack) -> Void)?
    /// The list of body components to be displayed in the stack.
    private var installedContents: [UIView] = []
    public var contentViews: FBody
    
    /// Initializes a stack with an optional single body component.
    /// - Parameter contentView: A single content component to display.
    public init(contentView: FBodyComponent? = nil) {
        if let contentView {
            self.contentViews = [contentView]
        } else {
            self.contentViews = []
        }
        super.init(frame: .zero)
    }
    
    /// Initializes a stack using a view builder that returns body components.
    /// - Parameter builder: A closure that returns an array of body components.
    public convenience init(@FViewBuilder _ builder: () -> FBody) {
        self.init(contentViews: builder())
    }
    
    /// Initializes a stack with a list of body components.
    /// - Parameter contentViews: An array of body components to compose into the stack.
    public init(contentViews: FBody) {
        self.contentViews = contentViews
        super.init(frame: .zero)
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configuration?.didMoveToSuperview(superview, with: self)
        updateContent()
        customConfiguration?(self)
    }

    public func updateContent() {
        let desired = contentViews.flatMap { ($0 as? FForEach)?.content() ?? [$0] }
        let identities = Set(desired.map { ObjectIdentifier($0) })
        installedContents.filter { !identities.contains(ObjectIdentifier($0)) }
            .forEach { $0.removeFromSuperview() }
        for view in desired {
            if view.superview !== self { addSubview(view) }
            bringSubviewToFront(view)
        }
        installedContents = desired
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        configuration?.updateLayers(for: self)
    }
}
