import Foundation

// MARK: - SortOption

/// How the venue list is ordered.
///
/// This is the **type only** — the actual sorting logic (and the picker UI that
/// drives it) lands in a later PR. It exists now so ``AppPreferences`` can
/// persist a `defaultSort` and so the eventual sort menu can iterate
/// ``allCases`` for its rows.
///
/// `rawValue` is the persisted form, so the case names are part of the storage
/// contract — renaming a case would orphan a user's saved preference.
enum SortOption: String, CaseIterable, Sendable, Codable, Identifiable {
    case nearest
    case priceLowToHigh
    case mostCourts
    case alphabetical

    var id: String { rawValue }

    /// Human-readable label for the sort menu row.
    var label: String {
        switch self {
        case .nearest: "Nearest"
        case .priceLowToHigh: "Price (low→high)"
        case .mostCourts: "Most courts"
        case .alphabetical: "A–Z"
        }
    }

    /// SF Symbol shown alongside the label.
    var systemImage: String {
        switch self {
        case .nearest: "location.fill"
        case .priceLowToHigh: "dollarsign"
        case .mostCourts: "sportscourt.fill"
        case .alphabetical: "textformat.abc"
        }
    }
}
