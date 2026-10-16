//
//  UIView+FConfiguration.swift
//  DesignUIKit
//
//  Created by Duke Nguyen on 2024/02/24.
//
//  Adds support for attaching `FConfiguration` objects to any UIView instance
//  via associated objects, and provides view assignment utilities.
//

import UIKit
import DesignCore

/// Adds an associated `FConfiguration` object to any `UIView`.
/// Enables configuration sharing and mutation through dynamic properties.
@MainActor public extension UIView {
    /// The shared object association for storing configurations per view.
    static var configuration = ObjectAssociation<FConfiguration>()
    
    /// Gets or sets the configuration object associated with the view.
    var configuration: FConfiguration? {
        get { Self.configuration[self] }
        set {
            Self.configuration[self] = newValue
            newValue?.owner = self
        }
    }
}

/// A protocol that allows a view to assign itself to an external reference.
/// Useful for capturing views for later manipulation within a declarative context.
@MainActor public protocol FAssignable {
    @discardableResult
    func assign<View: FBodyComponent>(to target: inout View?) -> Self
}

public extension FAssignable {
    /// Assigns the current view instance to the given target reference.
    /// - Parameter target: The target reference to assign to.
    /// - Returns: The instance itself cast as the target type.
    @discardableResult
    func assign<View: FBodyComponent>(to target: inout View?) -> Self {
        target = self as? View
        return self
    }
}
