import Foundation

private let dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

/// Maps a 0-based day-of-week index to its abbreviated name.
/// Returns "Day N" for any index outside 0...6 (mirrors RN fallback).
func dayLabel(_ dayOfWeek: Int) -> String {
    guard dayOfWeek >= 0, dayOfWeek < dayLabels.count else {
        return "Day \(dayOfWeek)"
    }
    return dayLabels[dayOfWeek]
}

/// Converts a "HH:MM" or "HH:MM:SS" time string to 12-hour format with am/pm.
/// Returns "—" for nil/empty input; returns the original string when parsing fails.
func formatTime(_ t: String?) -> String {
    guard let t, !t.isEmpty else { return "—" }
    let parts = t.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
    guard
        parts.count >= 2,
        let h = Int(parts[0]),
        let m = Int(parts[1])
    else {
        return t
    }
    let suffix = h < 12 ? "am" : "pm"
    let hour = h % 12 == 0 ? 12 : h % 12
    let mm = String(format: "%02d", m)
    return "\(hour):\(mm) \(suffix)"
}

private let abbrToLabel: [String: String] = [
    "mon": "Mon", "tue": "Tue", "wed": "Wed",
    "thu": "Thu", "fri": "Fri", "sat": "Sat", "sun": "Sun",
]

/// Formats a list of day abbreviations into a human-readable string.
func formatDays(_ days: [String]) -> String {
    if days.isEmpty { return "All days" }
    if days.count == 7 { return "Every day" }
    return days.map { abbrToLabel[$0] ?? $0 }.joined(separator: ", ")
}
