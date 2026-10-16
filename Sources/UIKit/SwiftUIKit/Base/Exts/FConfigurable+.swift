//
//  FConfigurable+.swift
//  DesignUIKit
//
//  Created by Duke Nguyen on 2024/02/15.
//
//  Extensions for `FConfigurable` to provide fluent-style convenience methods
//  for configuring layout, appearance, padding, and other view properties.
//

import UIKit
import DesignExts
import DesignCore

public extension FConfigurable {
    /// Adds a modifier to the configuration.
    ///
    /// - Parameter modifier: The modifier to append.
    /// - Returns: Self for chaining.
    @discardableResult func modified(with modifier: FModifier) -> Self {
        configuration?.modifiers.append(modifier)
        if let view = self as? FBodyComponent, view.superview != nil {
            configuration?.applyModifiers(to: view)
        }
        return self
    }
    
    /// Clears all modifiers from the configuration.
    ///
    /// - Returns: Self for chaining.
    @discardableResult func clearModifiers() -> Self {
        configuration?.restoreModifiers()
        configuration?.modifiers = []
        configuration?.clearModifiers = true
        return self
    }
    
    /// Offsets the view by the specified size.
    ///
    /// - Parameter size: The size to offset by.
    /// - Returns: Self for chaining.
    @discardableResult func offset(_ size: CGSize) -> Self {
        offset(width: size.width, height: size.height)
    }
    
    /// Offsets the view by the specified width and height.
    ///
    /// - Parameters:
    ///   - width: The horizontal offset.
    ///   - height: The vertical offset.
    /// - Returns: Self for chaining.
    @discardableResult func offset(width: CGFloat, height: CGFloat) -> Self {
        configuration?.offset = .init(
            width: width + (configuration?.offset.width ?? 0),
            height: height + (configuration?.offset.height ?? 0)
        )
        return self
    }
    
    /// Applies a default padding of 8 points to all edges.
    ///
    /// - Returns: Self for chaining.
    @discardableResult func padding() -> Self {
        self.padding(8)
    }
    
    /// Applies the specified directional insets as padding.
    ///
    /// - Parameter insets: The directional edge insets to apply.
    /// - Returns: Self for chaining.
    @discardableResult func padding(_ insets: NSDirectionalEdgeInsets) -> Self {
        [
            (insets.top, .top),
            (insets.leading, .leading),
            (insets.bottom, .bottom),
            (insets.trailing, .trailing)
        ].forEach(configuration?.update ?? { _, _ in })
        return self
    }

    @discardableResult func padding(_ padding: CGFloat) -> Self {
        self.padding(.all, padding)
    }

    @discardableResult func padding(_ edges: FDirectionalRectEdge, _ padding: CGFloat) -> Self {
        edges.rawEdges.map { (padding, $0) }.forEach(configuration?.update ?? { _, _ in })
        return self
    }

    @discardableResult func padding(with style: SpacingSystem.CommonSpacing) -> Self {
        padding(SpacingSystem.shared.spacing(style))
    }

    @discardableResult func padding(_ edges: FDirectionalRectEdge, with style: SpacingSystem.CommonSpacing) -> Self {
        padding(edges, SpacingSystem.shared.spacing(style))
    }
    
    @discardableResult func ignore(edges: FDirectionalRectEdge) -> Self {
        edges.rawEdges.forEach { configuration?.containerPadding.removeValue(forKey: $0) }
        return self
    }

    @discardableResult func background(_ color: UIColor) -> Self {
        configuration?.with(\.backgroundColor, setTo: color)
        return self
    }
    
    /// Applies a shape configuration to the view.
    ///
    /// - Parameter shape: The shape to apply.
    /// - Returns: Self for chaining.
    @discardableResult func shaped(_ shape: FShape) -> Self {
        configuration?.with(\.shape, setTo: shape)
        return self
    }
    
    /// Applies a shadow configuration to the view.
    ///
    /// - Parameter shadow: The shadow configuration.
    /// - Returns: Self for chaining.
    @discardableResult func shadow(_ shadow: CALayer.ShadowConfiguration) -> Self {
        configuration?.with(\.shadow, setTo: shadow)
        return self
    }
    
    /// Sets the opacity of the view.
    ///
    /// - Parameter opacity: The opacity value.
    /// - Returns: Self for chaining.
    @discardableResult func opacity(_ opacity: CGFloat) -> Self {
        configuration?.with(\.opacity, setTo: opacity)
        return self
    }
    
    /// Sets the aspect ratio of the view.
    ///
    /// - Parameter ratio: The aspect ratio to apply.
    /// - Returns: Self for chaining.
    @discardableResult func ratio(_ ratio: CGFloat) -> Self {
        configuration?.with(\.ratio, setTo: ratio)
        return self
    }
    
    /// Configures whether the view should ignore the safe area.
    ///
    /// - Parameter status: A Boolean value indicating whether to ignore safe area.
    /// - Returns: Self for chaining.
    @discardableResult func ignoreSafeArea(_ status: Bool) -> Self {
        configuration?.with(\.shouldIgnoreSafeArea, setTo: status)
        return self
    }
    
    /// Configures whether the view should attach to its parent.
    ///
    /// - Parameter status: A Boolean value indicating whether to attach to parent.
    /// - Returns: Self for chaining.
    @discardableResult func attachToParent(_ status: Bool) -> Self {
        configuration?.with(\.shouldConstraintWithParent, setTo: status)
        return self
    }
    
    /// Sets the height of the view.
    ///
    /// - Parameter height: The height to set.
    /// - Returns: Self for chaining.
    @discardableResult func frame(height: CGFloat) -> Self {
        configuration?.with(\.height, setTo: height)
        return self
    }
    
    /// Sets the width of the view.
    ///
    /// - Parameter width: The width to set.
    /// - Returns: Self for chaining.
    @discardableResult func frame(width: CGFloat) -> Self {
        configuration?.with(\.width, setTo: width)
        return self
    }
    
    /// Sets both the width and height of the view.
    ///
    /// - Parameters:
    ///   - width: The width to set.
    ///   - height: The height to set.
    /// - Returns: Self for chaining.
    @discardableResult func frame(width: CGFloat, height: CGFloat) -> Self {
        configuration?.with(\.height, setTo: height).with(\.width, setTo: width)
        return self
    }

    @discardableResult func center(axis: FAxis) -> Self {
        center(axis: axis, offset: 0)
    }
    
    @discardableResult func center(axis: FAxis, offset: CGFloat) -> Self {
        axis.rawAxes.forEach { configuration?.centerOffset[$0] = (configuration?.centerOffset[$0] ?? 0) + offset }
        return self
    }
    
    /// Centers the view in its parent with zero offset.
    ///
    /// - Returns: Self for chaining.
    @discardableResult func centerInParent() -> Self {
        centerInParent(offset: .zero)
    }
    
    /// Centers the view in its parent with the specified offset.
    ///
    /// - Parameter offset: The offset to apply when centering.
    /// - Returns: Self for chaining.
    @discardableResult func centerInParent(offset: CGSize) -> Self {
        configuration?.centerOffset[.vertical] = (configuration?.centerOffset[.vertical] ?? 0) + offset.width
        configuration?.centerOffset[.horizontal] = (configuration?.centerOffset[.horizontal] ?? 0) + offset.height
        return self
    }
    
    /// Sets the layout priority for constraints.
    ///
    /// - Parameter priority: The constraint priority.
    /// - Returns: Self for chaining.
    @discardableResult func layoutPriority(_ priority: ConstraintPriority) -> Self {
        configuration?.layoutPriority = priority
        return self
    }
    
    /// Enables or disables layer change animations.
    ///
    /// - Parameter isEnabled: Whether to animate layer changes.
    /// - Returns: Self for chaining.
    @discardableResult func shouldAnimateLayer(_ isEnabled: Bool) -> Self {
        configuration?.shoudAnimateLayerChanges = isEnabled
        return self
    }
    
    /// Configures the layout using a closure.
    ///
    /// - Parameter layoutConfiguration: Closure to configure layout with ConstraintMaker and superview.
    /// - Returns: Self for chaining.
    @discardableResult func layout(_ layoutConfiguration: @escaping (_ make: ConstraintMaker, _ superview: UIView) -> Void) -> Self {
        configuration?.with(\.layoutConfiguration, setTo: layoutConfiguration)
        return self
    }
    
    /// Configures the layer using a closure.
    ///
    /// - Parameter layerConfiguration: Closure to configure the layer of the view.
    /// - Returns: Self for chaining.
    @discardableResult func layer(_ layerConfiguration: @escaping (UIView) -> Void) -> Self {
        configuration?.with(\.layerConfiguration, setTo: layerConfiguration)
        return self
    }
}
