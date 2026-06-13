import Foundation

/// Formats a price stored in cents as a dollar-per-hour string.
/// Returns "Rates not listed" when cents is nil.
/// Rounds to the nearest dollar using standard rounding (matches JS toFixed(0)).
func formatPriceCents(_ cents: Int?) -> String {
    guard let cents else { return "Rates not listed" }
    let dollars = Int((Double(cents) / 100).rounded())
    return "$\(dollars)/hr"
}
