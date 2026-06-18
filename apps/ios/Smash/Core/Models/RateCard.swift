import Foundation

struct RateCard: Codable, Identifiable, Sendable, Equatable {
    let id: String
    let label: String
    let priceCents: Int
    let daysApply: [String]
    let timeRangeStart: String?
    let timeRangeEnd: String?
    let notes: String?
}

// MARK: - Note classification (UX fix #5)

extension RateCard {

    /// The maximum length a `notes` string may be to still read as a short,
    /// label-like *tag* (e.g. "Most popular", "Best value") rather than long
    /// policy prose. Tuned so concise tags pass and sentence fragments don't.
    static let shortTagMaxLength = 22

    /// `notes` interpreted as a short semantic **tag** — returned only when the
    /// note is concise and label-like (short, no sentence punctuation), suitable
    /// for the inline pill. Otherwise `nil`.
    ///
    /// Heuristic: the trimmed note is a tag when it is at most
    /// ``shortTagMaxLength`` characters and contains no period (a period implies
    /// sentence/policy prose). Pure and side-effect-free for testability.
    var shortTag: String? {
        guard let trimmed = trimmedNotes else { return nil }
        guard trimmed.count <= Self.shortTagMaxLength, !trimmed.contains(".") else { return nil }
        return trimmed
    }

    /// `notes` interpreted as long **policy** text — returned only when the note
    /// is *not* a short tag (i.e. it's long and/or sentence-like). Suitable for
    /// the wrapping "Good to know" section. Otherwise `nil`.
    var policyNote: String? {
        guard let trimmed = trimmedNotes else { return nil }
        return shortTag == nil ? trimmed : nil
    }

    /// `notes` trimmed of surrounding whitespace/newlines, or `nil` when absent
    /// or empty after trimming.
    private var trimmedNotes: String? {
        guard let notes else { return nil }
        let trimmed = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
