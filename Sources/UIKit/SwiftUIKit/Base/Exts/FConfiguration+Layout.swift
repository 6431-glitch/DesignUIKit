import UIKit
import SnapKit

extension FConfiguration {
    /// Flushes this view's pending layout changes. Existing constraints are retained
    /// when only their constants change; consumer-owned constraints are untouched.
    public func applyLayout() {
        guard let view = owner else { return }
        let parentChanged = layoutSuperview !== view.superview
        guard layoutNeedsUpdate || parentChanged else { return }
        layoutNeedsUpdate = false
        if parentChanged {
            customLayoutNeedsUpdate = true
            layoutSuperview = view.superview
        }
        guard let parent = view.superview else {
            NSLayoutConstraint.deactivate(Array(ownedLayoutConstraints.values))
            ownedLayoutConstraints.removeAll()
            customLayoutConstraints.forEach { $0.deactivate() }
            customLayoutConstraints.removeAll()
            return
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        var desired: [String: NSLayoutConstraint] = [:]
        let guide = parent.safeAreaLayoutGuide
        if shouldConstraintWithParent && !isLayoutManagedByContainer {
            if let x = centerOffset[.vertical] {
                desired["centerX"] = view.centerXAnchor.constraint(
                    equalTo: shouldIgnoreSafeArea ? parent.centerXAnchor : guide.centerXAnchor,
                    constant: x)
            } else {
                if let inset = containerPadding[.leading] {
                    desired["leading"] = view.leadingAnchor.constraint(
                        equalTo: shouldIgnoreSafeArea ? parent.leadingAnchor : guide.leadingAnchor,
                        constant: offset.width + inset)
                }
                if let inset = containerPadding[.trailing] {
                    desired["trailing"] = view.trailingAnchor.constraint(
                        equalTo: shouldIgnoreSafeArea ? parent.trailingAnchor : guide.trailingAnchor,
                        constant: offset.width - inset)
                }
            }
            if let y = centerOffset[.horizontal] {
                desired["centerY"] = view.centerYAnchor.constraint(
                    equalTo: shouldIgnoreSafeArea ? parent.centerYAnchor : guide.centerYAnchor,
                    constant: y)
            } else {
                if let inset = containerPadding[.top] {
                    desired["top"] = view.topAnchor.constraint(
                        equalTo: shouldIgnoreSafeArea ? parent.topAnchor : guide.topAnchor,
                        constant: offset.height + inset)
                }
                if let inset = containerPadding[.bottom] {
                    desired["bottom"] = view.bottomAnchor.constraint(
                        equalTo: shouldIgnoreSafeArea ? parent.bottomAnchor : guide.bottomAnchor,
                        constant: offset.height - inset)
                }
            }
        }
        if let width, width > 0 {
            desired["width"] = view.widthAnchor.constraint(equalToConstant: width)
        }
        if let height, height > 0 {
            desired["height"] = view.heightAnchor.constraint(equalToConstant: height)
        }
        if let ratio, ratio > 0 {
            desired["ratio"] = view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: ratio)
        }
        for key in Array(ownedLayoutConstraints.keys) where desired[key] == nil {
            ownedLayoutConstraints.removeValue(forKey: key)?.isActive = false
        }
        for (key, candidate) in desired {
            candidate.priority = UILayoutPriority(layoutPriority.value)
            if let existing = ownedLayoutConstraints[key],
               existing.firstItem === candidate.firstItem,
               existing.secondItem === candidate.secondItem,
               existing.firstAttribute == candidate.firstAttribute,
               existing.secondAttribute == candidate.secondAttribute,
               existing.multiplier == candidate.multiplier,
               existing.priority == candidate.priority {
                existing.constant = candidate.constant
                existing.isActive = true
            } else {
                ownedLayoutConstraints[key]?.isActive = false
                candidate.identifier = "FastView.\(key)"
                ownedLayoutConstraints[key] = candidate
                candidate.isActive = true
            }
        }
        if customLayoutNeedsUpdate {
            customLayoutNeedsUpdate = false
            customLayoutConstraints.forEach { $0.deactivate() }
            customLayoutConstraints = view.snp.prepareConstraints { make in
                layoutConfiguration?(make, parent)
            }
            customLayoutConstraints.forEach { $0.activate() }
        }
    }
}
