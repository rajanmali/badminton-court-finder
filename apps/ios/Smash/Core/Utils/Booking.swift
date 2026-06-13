import Foundation

// MARK: - BookingAction

enum BookingAction: Equatable, Sendable {
    case url(label: String, href: String)
    case phone(label: String, href: String)
    case email(label: String, href: String)
    case none
}

// MARK: - getBookingAction

/// Returns the highest-priority contact action for a venue.
/// Priority: bookingUrl > phone > email > none.
/// Whitespace (spaces and newlines) is stripped from phone numbers; parentheses are kept.
func getBookingAction(bookingUrl: String, phone: String?, email: String?) -> BookingAction {
    if !bookingUrl.isEmpty {
        return .url(label: "Book a court", href: bookingUrl)
    }
    if let phone, !phone.isEmpty {
        let stripped = phone.components(separatedBy: .whitespacesAndNewlines).joined()
        return .phone(label: "Call venue", href: "tel:" + stripped)
    }
    if let email, !email.isEmpty {
        return .email(label: "Email venue", href: "mailto:" + email)
    }
    return .none
}
