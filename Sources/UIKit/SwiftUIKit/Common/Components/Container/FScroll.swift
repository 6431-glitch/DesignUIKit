//
//  FScroll.swift
//  DesignUIKit
//
//  Created by Duke Nguyen on 2024/02/12.
//
//  A customizable scroll view component that supports vertical or horizontal layout
//  of body components using fluent composition.
//

import UIKit
import DesignCore

/// A customizable scroll view component that supports arranging `FBodyComponent` views
/// either vertically or horizontally using declarative initialization and composition.
public final class FScroll: BaseScrollView, FComponent {
    /// The scroll direction of the content (horizontal or vertical).
    public var axis: NSLayoutConstraint.Axis
    /// The views to be arranged inside the scroll view.
    public var contentViews: [FBodyComponent] = []
    /// Optional closure for applying additional configuration to the scroll view.
    public var customConfiguration: ((FScroll) -> Void)?
    private var hasSetupContent: Bool = false
    private var contentConstraints: [NSLayoutConstraint] = []
    private var installedContents: [UIView] = []
    
    /// Initializes a scroll view with a single optional body component.
    /// - Parameters:
    ///   - axis: The scroll direction.
    ///   - contentView: A single content view to display.
    public init(
        axis: NSLayoutConstraint.Axis,
        contentView: FBodyComponent? = nil
    ) {
        self.axis = axis
        if let contentView {
            self.contentViews = [contentView]
        } else {
            self.contentViews = []
        }
        super.init(frame: .zero)
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    /// Initializes a scroll view with multiple body components using a builder.
    /// - Parameters:
    ///   - axis: The scroll direction.
    ///   - contentViews: A view builder closure that returns the scrollable content.
    public init(
        axis: NSLayoutConstraint.Axis,
        @FViewBuilder contentViews: () -> FBody
    ) {
        self.axis = axis
        self.contentViews = contentViews()
        super.init(frame: .zero)
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        switch axis {
        case .horizontal:
            alwaysBounceHorizontal = true
        case .vertical:
            alwaysBounceVertical = true
        @unknown default:
            break
        }
        configuration?.didMoveToSuperview(superview, with: self)
        setupContentIfNeeded()
        customConfiguration?(self)
    }
    
    private func setupContentIfNeeded() {
        guard !hasSetupContent else { return }
        hasSetupContent = true

        let flattened = contentViews.flatMap {
            ($0 as? FForEach)?.content() ?? [$0]
        }
        guard !flattened.isEmpty else { return }

        installedContents = flattened
        var previousView: UIView?
        for view in flattened {
            if view.superview !== self {
                addSubview(view.attachToParent(false))
            }
            view.translatesAutoresizingMaskIntoConstraints = false
            switch axis {
            case .horizontal:
                installConstraints([
                    view.topAnchor.constraint(equalTo: frameLayoutGuide.topAnchor),
                    view.bottomAnchor.constraint(equalTo: frameLayoutGuide.bottomAnchor),
                    view.leadingAnchor.constraint(
                        equalTo: previousView?.trailingAnchor ?? contentLayoutGuide.leadingAnchor,
                        constant: view.configuration?.containerPadding[.leading] ?? 0
                    )
                ])
            case .vertical:
                installConstraints([
                    view.topAnchor.constraint(
                        equalTo: previousView?.bottomAnchor ?? contentLayoutGuide.topAnchor,
                        constant: view.configuration?.containerPadding[.top] ?? 0
                    ),
                    view.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor)
                ])
            @unknown default:
                installConstraints([
                    view.topAnchor.constraint(
                        equalTo: previousView?.bottomAnchor ?? contentLayoutGuide.topAnchor,
                        constant: view.configuration?.containerPadding[.top] ?? 0
                    ),
                    view.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor),
                    view.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor)
                ])
            }
            previousView = view
        }

        guard let lastView = previousView else { return }
        switch axis {
        case .horizontal:
            installConstraints([
                lastView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
                lastView.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor)
            ])
        case .vertical:
            installConstraints([
                lastView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
                lastView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor)
            ])
        @unknown default:
            installConstraints([
                lastView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
                lastView.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor)
            ])
        }
    }
    
    private func installConstraints(_ constraints: [NSLayoutConstraint]) {
        contentConstraints.append(contentsOf: constraints)
        NSLayoutConstraint.activate(constraints)
    }

    public func updateContent() {
        NSLayoutConstraint.deactivate(contentConstraints)
        contentConstraints.removeAll()
        let desired = contentViews.flatMap { ($0 as? FForEach)?.content() ?? [$0] }
        let identities = Set(desired.map { ObjectIdentifier($0) })
        installedContents.filter { !identities.contains(ObjectIdentifier($0)) }
            .forEach { $0.removeFromSuperview() }
        installedContents = []
        hasSetupContent = false
        setupContentIfNeeded()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        configuration?.updateLayers(for: self)
    }
}
