//
//  FComponent.swift
//  DesignUIKit
//
//  Created by Duke Nguyen on 2024/02/11.
//
//  Defines protocols and utilities for building configurable UI components,
//  including support for chaining, content insets, and layout priorities.
//

import UIKit
import DesignCore
import DesignExts

/// A protocol representing a configurable UI component that supports chaining and custom configuration.
///
/// Conforming types are expected to provide an optional configuration object and allow setting a custom configuration closure.
@MainActor public protocol FComponent: AnyObject, Chainable {
    /// The configuration object for the component.
    var configuration: FConfiguration? { get }
    
    /// A closure for applying custom configuration to the component.
    var customConfiguration: ((Self) -> Void)? { get set }
    func reload()
    /// Updates owned content explicitly, without simulating UIKit lifecycle events.
    func updateContent()
}

extension FComponent where Self: UIView {
    /// Leaf components retain their UIKit-managed subviews on reload.
    public func updateContent() { }

    public func reload() {
        if let target = self as? FBodyComponent {
            configuration?.didMoveToSuperview(superview, with: target)
        }
        updateContent()
        customConfiguration?(self)
    }
}

public extension FComponent {
    /// Sets a custom configuration closure for the component.
    ///
    /// - Parameter configuration: A closure that receives the component instance for customization.
    /// - Returns: The component instance for chaining.
    @discardableResult func customConfiguration(_ configuration: ((Self) -> Void)?) -> Self {
        with(\.customConfiguration, setTo: configuration)
    }
}

/// A protocol for UI components that support setting content hugging and compression resistance priorities.
@MainActor public protocol FContentConstraintable: AnyObject {
    /// Sets the content hugging priority for a given axis.
    ///
    /// - Parameters:
    ///   - priority: The priority level to set.
    ///   - axis: The layout axis (horizontal or vertical).
    /// - Returns: The component instance for chaining.
    @discardableResult
    func huggingPriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self
    
    /// Sets the content compression resistance priority for a given axis.
    ///
    /// - Parameters:
    ///   - priority: The priority level to set.
    ///   - axis: The layout axis (horizontal or vertical).
    /// - Returns: The component instance for chaining.
    @discardableResult
    func compressionResistancePriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self
}

public extension FContentConstraintable where Self: UIView {
    @discardableResult func huggingPriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self {
        setContentHuggingPriority(priority, for: axis)
        return self
    }
    
    @discardableResult func compressionResistancePriority(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self {
        setContentCompressionResistancePriority(priority, for: axis)
        return self
    }
}

/// A protocol for UI components that support setting content insets.
@MainActor
public protocol FContentAvailable: FContentConstraintable {
    /// Sets the content insets using a `UIEdgeInsets` value.
    ///
    /// - Parameter insets: The edge insets to apply.
    /// - Returns: The component instance for chaining.
    @discardableResult func insets(_ insets: UIEdgeInsets) -> Self
    
    /// Sets uniform content insets on all edges.
    ///
    /// - Parameter insets: The inset value to apply on all edges.
    /// - Returns: The component instance for chaining.
    @discardableResult func insets(_ insets: CGFloat) -> Self
    
    /// Sets content insets on specific edges.
    ///
    /// - Parameters:
    ///   - edges: The edges to apply the inset to.
    ///   - insets: The inset value to apply.
    /// - Returns: The component instance for chaining.
    @discardableResult func insets(_ edges: UIRectEdge, _ insets: CGFloat) -> Self
}

/// Provides `insets` configuration methods for `BaseLabel` to apply content padding.
public extension FContentAvailable where Self: BaseLabel {
    /// Adds the given edge insets to the current content insets.
    /// - Parameter insets: The `UIEdgeInsets` to add.
    /// - Returns: Self for method chaining.
    @discardableResult func insets(_ insets: UIEdgeInsets) -> Self {
        contentInsets += insets
        return self
    }
    
    /// Applies uniform insets on all edges of the label.
    /// - Parameter insets: The inset value for all sides.
    /// - Returns: Self for method chaining.
    @discardableResult func insets(_ insets: CGFloat) -> Self {
        self.insets(.all, insets)
    }
    
    /// Applies insets to specific edges of the label.
    /// - Parameters:
    ///   - edges: The edges to apply the inset to.
    ///   - insets: The inset value to apply.
    /// - Returns: Self for method chaining.
    @discardableResult func insets(_ edges: UIRectEdge, _ insets: CGFloat) -> Self {
        contentInsets = contentInsets.add(edges, insets)
        return self
    }
}

/// An enumeration that defines the visual shape of a UI component.
/// Used to apply predefined corner styles such as circular or rounded rectangle.
public enum FShape {
    /// A shape that applies a circular mask to the component.
    /// Typically used when the component’s width and height are equal.
    case circle
    
    /// A shape that applies a rounded rectangle mask to the component.
    ///
    /// - Parameters:
    ///   - cornerRadius: The radius to apply to the specified corners.
    ///   - corners: The corners to round. Defaults to all corners.
    case roundedRectangle(cornerRadius: CGFloat, corners: UIRectCorner = .allCorners)
}
