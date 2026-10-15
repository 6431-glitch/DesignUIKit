//
//  FStack.swift
//  DesignUIKit
//
//  Created by Duke Nguyen on 2024/02/11.
//
//  A flexible stack view component built on top of `UIStackView` that supports
//  declarative configuration of body components with vertical or horizontal layout.
//

import UIKit
import DesignCore

/// A flexible stack view component supporting vertical or horizontal layout.
/// Accepts an array of body components or a view builder closure for layout composition.
public class FStack: BaseStackView, FComponent {
    /// Optional closure for performing additional custom runtime configuration.
    public var customConfiguration: ((FStack) -> Void)?
    
    /// The list of components to be arranged in the stack view.
    public var arrangedContents: FBody {
        get { storedArrangedContents }
        set {
            storedArrangedContents = newValue
            keyedContentState = FKeyedContentState()
        }
    }
    private var storedArrangedContents: FBody
    var keyedContentState = FKeyedContentState()

    /// Installs keyed content without routing through the manual-content reset path.
    func installKeyedContent(_ content: FBody, state: FKeyedContentState) {
        storedArrangedContents = content
        keyedContentState = state
        updateContent()
    }

    /// Initializes a stack view with a view builder closure to generate arranged content.
    /// - Parameters:
    ///   - axis: The stack layout direction (horizontal or vertical).
    ///   - spacing: The spacing between arranged views.
    ///   - distribution: Optional stack distribution configuration.
    ///   - arrangedContents: A closure that returns the array of views to arrange.
    public init(
        axis: NSLayoutConstraint.Axis,
        spacing: Double = 8,
        distribution: UIStackView.Distribution? = nil,
        @FViewBuilder arrangedContents: () -> FBody
    ) {
        self.storedArrangedContents = arrangedContents()
        super.init(frame: .zero)
        self.axis = axis
        self.spacing = spacing
        self.distribution = distribution ?? .fill
    }
    
    /// Initializes a stack view with an existing array of arranged body components.
    /// - Parameters:
    ///   - axis: The stack layout direction (horizontal or vertical).
    ///   - spacing: The spacing between arranged views.
    ///   - distribution: Optional stack distribution configuration.
    ///   - arrangedContents: An array of views to arrange.
    public init(
        axis: NSLayoutConstraint.Axis,
        spacing: Double = 8,
        distribution: UIStackView.Distribution? = nil,
        arrangedContents: FBody
    ) {
        self.storedArrangedContents = arrangedContents
        super.init(frame: .zero)
        self.axis = axis
        self.spacing = spacing
        self.distribution = distribution ?? .fill
    }
    
    /// Adds the given body components to the stack view, flattening any `FForEach` components.
    /// - Parameter body: The array of views or wrappers to insert into the stack.
    func addContents(_ body: FBody) {
        let desired = body.flatMap { ($0 as? FForEach)?.content() ?? [$0] }
        let identities = Set(desired.map { ObjectIdentifier($0) })
        for view in arrangedSubviews where !identities.contains(ObjectIdentifier(view)) {
            removeArrangedSubview(view)
            view.removeFromSuperview()
            view.configuration?.isLayoutManagedByContainer = false
        }
        var inserted = Set<ObjectIdentifier>()
        for (index, view) in desired.enumerated() {
            guard inserted.insert(ObjectIdentifier(view)).inserted else { continue }
            if view.configuration?.isLayoutManagedByContainer != true {
                view.configuration?.isLayoutManagedByContainer = true
            }
            view.translatesAutoresizingMaskIntoConstraints = false
            if index >= arrangedSubviews.count || arrangedSubviews[index] !== view {
                // Reordering an arranged view keeps it in the view hierarchy.
                if arrangedSubviews.contains(where: { $0 === view }) {
                    removeArrangedSubview(view)
                }
                insertArrangedSubview(view, at: min(index, arrangedSubviews.count))
            }
        }
    }

    public func updateContent() {
        addContents(arrangedContents)
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configuration?.didMoveToSuperview(superview, with: self)
        addContents(arrangedContents)
        customConfiguration?(self)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        configuration?.updateLayers(for: self)
    }
}
