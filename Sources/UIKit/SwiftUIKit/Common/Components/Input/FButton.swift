//
//  FButton.swift
//  DesignUIKit
//
//  Created by Duke Nguyen on 11/02/2024.
//
//  A customizable and declarative button component that supports theming, configuration,
//  and flexible label content via `FBody` and `FViewBuilder`.
//

import UIKit
import DesignCore
import SnapKit

/// A customizable and declarative button that supports themes, configuration, and flexible label views.
///
/// `FButton` is a reusable component that allows you to define its label using a builder,
/// apply custom configuration logic, and easily connect actions or menus.
public final class FButton: BaseButton, FComponent, FCalligraphiable, FThemableForeground, FContentConstraintable {
    public var fontWrapper: UIFont {
        get { titleLabel?.font ?? .systemFont(ofSize: 17) }
        set { titleLabel?.font = newValue }
    }
    
    /// Platform-specific primary tap event (`.touchUpInside` or `.primaryActionTriggered`).
#if targetEnvironment(macCatalyst)
    public static let tapEvent: UIControl.Event = .primaryActionTriggered
    #else
    public static let tapEvent: UIControl.Event = .touchUpInside
#endif
    
    /// An optional closure used for performing additional custom configuration on the button.
    public var customConfiguration: ((FButton) -> Void)?
    
    /// A custom label view (or views) defined using `FBody` to be added as subviews.
    var label: FBody?
    
    /// Creates a button with a title and action.
    /// - Parameters:
    ///   - style: The button type.
    ///   - text: The button title.
    ///   - action: The tap action to invoke.
    public convenience init(style: UIButton.ButtonType? = nil, _ text: String = "", action: @escaping () -> Void) {
        self.init(style: style)
        setTitle(text, for: .normal)
        addAction(for: Self.tapEvent, action)
    }
    
    /// Creates a button with a label view builder and an optional action.
    /// - Parameters:
    ///   - style: The button type.
    ///   - label: A closure returning the label content as `FBody`.
    ///   - action: An optional tap action to invoke.
    public convenience init(style: UIButton.ButtonType? = nil, @FViewBuilder label: () -> FBody, action: (() -> Void)? = nil) {
        self.init(style: style, label: label(), action: action)
    }
    
    /// Creates a button with a label and an optional action.
    /// - Parameters:
    ///   - style: The button type.
    ///   - label: The label content as `FBody`.
    ///   - action: An optional tap action to invoke.
    public convenience init(style: UIButton.ButtonType? = nil, label: FBody, action: (() -> Void)? = nil) {
        self.init(style: style)
        if let action { addAction(for: Self.tapEvent, action) }
        self.label = label.flatMap {
            ($0 as? FForEach)?.content() ?? [$0]
        }
    }
    
    /// Creates a button with a title and an action receiving the button instance.
    /// - Parameters:
    ///   - style: The button type.
    ///   - text: The button title.
    ///   - action: The tap action to invoke with the button instance.
    public convenience init(style: UIButton.ButtonType? = nil, _ text: String = "", action: @escaping (FButton?) -> Void) {
        self.init(style: style)
        setTitle(text, for: .normal)
        addAction(for: Self.tapEvent, { [weak self] in action(self) })
    }
    
    /// Creates a button with a label view builder and an action receiving the button instance.
    /// - Parameters:
    ///   - style: The button type.
    ///   - label: A closure returning the label content as `FBody`.
    ///   - action: The tap action to invoke with the button instance.
    public convenience init(style: UIButton.ButtonType? = nil, @FViewBuilder label: () -> FBody, action: @escaping (FButton?) -> Void) {
        self.init(style: style)
        addAction(for: Self.tapEvent, { [weak self] in action(self) })
        self.label = label().flatMap {
            ($0 as? FForEach)?.content() ?? [$0]
        }
    }
    
    /// Creates a button with a label and an action receiving the button instance.
    /// - Parameters:
    ///   - style: The button type.
    ///   - label: The label content as `FBody`.
    ///   - action: The tap action to invoke with the button instance.
    public convenience init(style: UIButton.ButtonType? = nil, label: FBody, action: @escaping (FButton?) -> Void) {
        self.init(style: style)
        addAction(for: Self.tapEvent, { [weak self] in action(self) })
        self.label = label.flatMap {
            ($0 as? FForEach)?.content() ?? [$0]
        }
    }
    
    /// Creates a button with a label view builder and a menu, available on iOS 15.0 and tvOS 17.0 or later.
    /// - Parameters:
    ///   - style: The button type.
    ///   - label: A closure returning the label content as `FBody`.
    ///   - menu: The menu to display as primary action.
    @available(iOS 15.0, tvOS 17.0, *)
    public convenience init(style: UIButton.ButtonType? = nil, @FViewBuilder label: () -> FBody, menu: UIMenu) {
        self.init(style: style, label: label)
        self.showsMenuAsPrimaryAction = true
        self.changesSelectionAsPrimaryAction = true
        self.menu = menu
    }
    
    /// Creates a button with a label and a menu, available on iOS 15.0 and tvOS 17.0 or later.
    /// - Parameters:
    ///   - style: The button type.
    ///   - label: The label content as `FBody`.
    ///   - menu: The menu to display as primary action.
    @available(iOS 15.0, tvOS 17.0, *)
    public convenience init(style: UIButton.ButtonType? = nil, label: FBody, menu: UIMenu) {
        self.init(style: style, label: label)
        self.showsMenuAsPrimaryAction = true
        self.changesSelectionAsPrimaryAction = true
        self.menu = menu
    }
    
    /// Adds the custom label views as subviews and applies constraints if needed.
    func updateLabel() {
        label?.forEach { label in
            addSubview(label)
            label.isUserInteractionEnabled = false
            if label as? (any FComponent & UIView) == nil {
                label.snp.remakeConstraints {
                    $0.edges.equalToSuperview()
                }
            }
        }
    }
    
    /// Called when the button is added to a superview. Applies configuration and updates label.
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configuration?.didMoveToSuperview(superview, with: self)
        updateLabel()
        customConfiguration?(self)
    }
    
    /// Applies layer-related configuration updates after layout changes.
    public func updateContent() {
        updateLabel()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        configuration?.updateLayers(for: self)
    }
    
    /// Sets the font of the button’s title label.
    /// - Parameter font: The font to apply.
    /// - Returns: Self for chaining.
    @discardableResult public func font(_ font: UIFont) -> Self {
        titleLabel?.with(\.font, setTo: font)
        return self
    }
    
    /// Sets the text color of the button title for the `.normal` state.
    /// - Parameter color: The color to apply.
    /// - Returns: Self for chaining.
    @discardableResult public func foreground(_ color: UIColor) -> Self {
        setTitleColor(color, for: .normal)
        return self
    }
    
    /// The theme key used to apply a foreground color from the current theme.
    public var foregroundKey: ThemeKey?
    /// Applies the current theme to the button using its registered keys.
    /// - Parameter theme: The theme provider to resolve colors and styles from.
    public override func apply(theme: ThemeProvider) {
        super.apply(theme: theme)
        guard let foregroundKey else { return }
        foreground(theme.color(key: foregroundKey))
    }
}
