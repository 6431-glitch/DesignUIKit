//
//  FView.swift
//  DesignUIKit
//
//  Created by Duke Nguyen on 2024/02/20.
//
//  This file defines the `FView` class, a base class for configurable and declarative UI views
//  in the DesignUIKit framework. It provides a structure for building reusable and composable
//  UI components with custom configuration and layout behavior.
//

import UIKit
import Foundation
import DesignExts
import DesignCore

public typealias FBodyComponent = UIView & FConfigurable
public typealias FBody = [FBodyComponent]
public typealias FViewBuilder = FBuilder<FBodyComponent>

/// A base class for configurable and declarative UI views.
///
/// `FView` provides a structure for building reusable and composable UI components.
/// Subclasses should override the `body` property to define their view hierarchy,
/// and can customize appearance and layout using the provided configuration hooks.
open class FView: BaseView, FComponent {
    /// An optional closure for applying custom configuration to the view.
    ///
    /// Use this closure to perform additional setup or styling that is not covered by
    /// the standard configuration mechanisms.
    public var customConfiguration: ((FView) -> Void)?
    private var hasConfiguredViews: Bool = false
    
    /// Called when the view is added to a superview.
    ///
    /// This override notifies the configuration object, sets up the view hierarchy
    /// by calling `configureViews()`, and then applies any custom configuration.
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configuration?.didMoveToSuperview(superview, with: self)
        if superview != nil, !hasConfiguredViews {
            hasConfiguredViews = true
            configureViews()
        }
        customConfiguration?(self)
    }
    
    /// Lays out subviews and updates view layers.
    ///
    /// This override notifies the configuration object to update the view's layers
    /// after layout changes.
    open override func layoutSubviews() {
        super.layoutSubviews()
        configuration?.updateLayers(for: self)
    }
    
    /// Configures the view hierarchy.
    ///
    /// Subclasses can override this method to add additional subviews or customize
    /// the arrangement of the view's body. The default implementation adds the `body`
    /// component as a subview.
    open func configureViews() {
        addSubview(body)
    }
    
    /// Explicit content reload rebuilds this component's body only.
    open func updateContent() {
        subviews.forEach { $0.removeFromSuperview() }
        hasConfiguredViews = true
        configureViews()
    }

    /// The main content view of the component.
    ///
    /// Subclasses **must** override this computed property to provide their custom view hierarchy.
    /// The default implementation triggers a runtime error.
    open var body: FBodyComponent {
        fatalError("Variable body of \(String(describing: self)) must be overridden")
    }
}
