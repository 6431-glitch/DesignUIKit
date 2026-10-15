import UIKit
import SnapKit

/// Stable internal rule keys. Raw values also preserve existing debug identifiers.
enum FLayoutConstraintKey: String {
    case leading, trailing, top, bottom, centerX, centerY, width, height, ratio

    var identifier: String { "FastView.\(rawValue)" }
}

extension FConfiguration {
    /// Flushes this view's pending layout changes. Constant-only changes retain
    /// existing constraints; consumer-owned constraints remain untouched.
    public func applyLayout() {
        guard let view = owner else { return }
        let parentChanged = layoutSuperview !== view.superview
        guard layoutNeedsUpdate || parentChanged else { return }
        layoutNeedsUpdate = false
        updateLayoutParent(view.superview)

        guard let parent = view.superview else {
            removeOwnedConstraints()
            return
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        reconcileConstraints(desiredConstraints(for: view, in: parent))
        applyCustomLayout(to: view, in: parent)
    }

    private func updateLayoutParent(_ parent: UIView?) {
        guard layoutSuperview !== parent else { return }
        layoutSuperview = parent
        customLayoutNeedsUpdate = true
    }

    private func removeOwnedConstraints() {
        NSLayoutConstraint.deactivate(Array(ownedLayoutConstraints.values))
        ownedLayoutConstraints.removeAll()
        customLayoutConstraints.forEach { $0.deactivate() }
        customLayoutConstraints.removeAll()
    }

    private func desiredConstraints(for view: UIView, in parent: UIView) -> [FLayoutConstraintKey: NSLayoutConstraint] {
        var desired = sizingConstraints(for: view)
        if shouldConstraintWithParent && !isLayoutManagedByContainer {
            desired.merge(horizontalConstraints(for: view, in: parent)) { _, new in new }
            desired.merge(verticalConstraints(for: view, in: parent)) { _, new in new }
        }
        return desired
    }

    private func horizontalConstraints(for view: UIView, in parent: UIView) -> [FLayoutConstraintKey: NSLayoutConstraint] {
        let guide = parent.safeAreaLayoutGuide
        // Compatibility: FAxis names describe the line, not the moving coordinate.
        // .vertical stores the X offset; .horizontal stores the Y offset below.
        if let x = centerOffset[.vertical] {
            return [.centerX: view.centerXAnchor.constraint(
                equalTo: shouldIgnoreSafeArea ? parent.centerXAnchor : guide.centerXAnchor,
                constant: x)]
        }
        var desired: [FLayoutConstraintKey: NSLayoutConstraint] = [:]
        if let inset = containerPadding[.leading] {
            desired[.leading] = view.leadingAnchor.constraint(
                equalTo: shouldIgnoreSafeArea ? parent.leadingAnchor : guide.leadingAnchor,
                constant: offset.width + inset)
        }
        if let inset = containerPadding[.trailing] {
            desired[.trailing] = view.trailingAnchor.constraint(
                equalTo: shouldIgnoreSafeArea ? parent.trailingAnchor : guide.trailingAnchor,
                constant: offset.width - inset)
        }
        return desired
    }

    private func verticalConstraints(for view: UIView, in parent: UIView) -> [FLayoutConstraintKey: NSLayoutConstraint] {
        let guide = parent.safeAreaLayoutGuide
        if let y = centerOffset[.horizontal] {
            return [.centerY: view.centerYAnchor.constraint(
                equalTo: shouldIgnoreSafeArea ? parent.centerYAnchor : guide.centerYAnchor,
                constant: y)]
        }
        var desired: [FLayoutConstraintKey: NSLayoutConstraint] = [:]
        if let inset = containerPadding[.top] {
            desired[.top] = view.topAnchor.constraint(
                equalTo: shouldIgnoreSafeArea ? parent.topAnchor : guide.topAnchor,
                constant: offset.height + inset)
        }
        if let inset = containerPadding[.bottom] {
            desired[.bottom] = view.bottomAnchor.constraint(
                equalTo: shouldIgnoreSafeArea ? parent.bottomAnchor : guide.bottomAnchor,
                constant: offset.height - inset)
        }
        return desired
    }

    private func sizingConstraints(for view: UIView) -> [FLayoutConstraintKey: NSLayoutConstraint] {
        var desired: [FLayoutConstraintKey: NSLayoutConstraint] = [:]
        if let width, width > 0 {
            desired[.width] = view.widthAnchor.constraint(equalToConstant: width)
        }
        if let height, height > 0 {
            desired[.height] = view.heightAnchor.constraint(equalToConstant: height)
        }
        if let ratio, ratio > 0 {
            desired[.ratio] = view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: ratio)
        }
        return desired
    }

    private func reconcileConstraints(_ desired: [FLayoutConstraintKey: NSLayoutConstraint]) {
        for key in Array(ownedLayoutConstraints.keys) where desired[key] == nil {
            ownedLayoutConstraints.removeValue(forKey: key)?.isActive = false
        }
        for (key, candidate) in desired {
            candidate.priority = UILayoutPriority(layoutPriority.value)
            if let existing = ownedLayoutConstraints[key], existing.hasSameTopology(as: candidate) {
                existing.constant = candidate.constant
                existing.isActive = true
            } else {
                ownedLayoutConstraints[key]?.isActive = false
                candidate.identifier = key.identifier
                ownedLayoutConstraints[key] = candidate
                candidate.isActive = true
            }
        }
    }

    private func applyCustomLayout(to view: UIView, in parent: UIView) {
        guard customLayoutNeedsUpdate else { return }
        customLayoutNeedsUpdate = false
        customLayoutConstraints.forEach { $0.deactivate() }
        customLayoutConstraints = view.snp.prepareConstraints { make in
            layoutConfiguration?(make, parent)
        }
        customLayoutConstraints.forEach { $0.activate() }
    }
}

private extension NSLayoutConstraint {
    /// Constants can change in place; changing topology or priority needs replacement.
    func hasSameTopology(as other: NSLayoutConstraint) -> Bool {
        firstItem === other.firstItem && secondItem === other.secondItem
            && firstAttribute == other.firstAttribute && secondAttribute == other.secondAttribute
            && relation == other.relation && multiplier == other.multiplier && priority == other.priority
    }
}
