import UIKit

/// Potential conflicts in toolkit-owned parent/size rules, not solver errors.
public enum FLayoutDiagnostic: Equatable, Sendable {
    case fixedWidthWithPinnedEdges
    case fixedHeightWithPinnedEdges

    public var message: String {
        switch self {
        case .fixedWidthWithPinnedEdges:
            return "Fixed width plus leading/trailing pins can conflict. Release an edge with ignore(edges:) or use attachToParent(false) for custom positioning."
        case .fixedHeightWithPinnedEdges:
            return "Fixed height plus top/bottom pins can conflict. Release an edge with ignore(edges:) or use attachToParent(false) for custom positioning."
        }
    }
}

public extension FConfigurable {
    /// Inspects configuration without changing views, constraints, or layout timing.
    func layoutDiagnostics() -> [FLayoutDiagnostic] {
        configuration?.layoutDiagnostics() ?? []
    }
}

public extension FConfiguration {
    /// Checks known sizing combinations only. Custom constraints, actual parent
    /// dimensions, and other UIKit constraints are outside this inspection.
    func layoutDiagnostics() -> [FLayoutDiagnostic] {
        guard shouldConstraintWithParent && !isLayoutManagedByContainer else { return [] }
        var issues: [FLayoutDiagnostic] = []
        if let width, width > 0, centerOffset[.vertical] == nil,
           containerPadding[.leading] != nil, containerPadding[.trailing] != nil {
            issues.append(.fixedWidthWithPinnedEdges)
        }
        if let height, height > 0, centerOffset[.horizontal] == nil,
           containerPadding[.top] != nil, containerPadding[.bottom] != nil {
            issues.append(.fixedHeightWithPinnedEdges)
        }
        return issues
    }
}
