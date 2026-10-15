import Foundation

/// Rejected keyed input. Indices are zero-based positions in the submitted array.
public enum FStackUpdateError: Error, Equatable, LocalizedError, Sendable {
    case duplicateIdentifier(firstIndex: Int, duplicateIndex: Int)
    case reusedView(firstIndex: Int, duplicateIndex: Int)

    public var errorDescription: String? {
        switch self {
        case let .duplicateIdentifier(first, duplicate):
            return "Duplicate item ID at index \(duplicate), first used at index \(first). Give each item a unique, stable ID."
        case let .reusedView(first, duplicate):
            return "View at index \(duplicate) is also used at index \(first). Return a distinct view from makeView for each new ID."
        }
    }
}
