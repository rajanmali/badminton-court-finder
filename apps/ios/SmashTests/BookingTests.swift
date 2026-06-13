import Testing
@testable import Smash

struct BookingTests {
    private let emptyBase = (bookingUrl: "", phone: String?.none, email: String?.none)

    @Test func returnsUrlActionWhenBookingUrlIsSet() {
        let result = getBookingAction(
            bookingUrl: "https://example.com/book",
            phone: nil,
            email: nil
        )
        #expect(result == .url(label: "Book a court", href: "https://example.com/book"))
    }

    @Test func returnsPhoneActionWhenBookingUrlEmptyAndPhoneSet() {
        let result = getBookingAction(bookingUrl: "", phone: "02 9123 4567", email: nil)
        #expect(result == .phone(label: "Call venue", href: "tel:0291234567"))
    }

    @Test func stripsSpacesFromPhoneNumberInHref() {
        let result = getBookingAction(bookingUrl: "", phone: "(02) 9911 6300", email: nil)
        #expect(result == .phone(label: "Call venue", href: "tel:(02)99116300"))
    }

    @Test func returnsEmailActionWhenUrlAndPhoneBothAbsent() {
        let result = getBookingAction(bookingUrl: "", phone: nil, email: "info@venue.com.au")
        #expect(result == .email(label: "Email venue", href: "mailto:info@venue.com.au"))
    }

    @Test func prefersUrlOverPhone() {
        let result = getBookingAction(
            bookingUrl: "https://book.me",
            phone: "0400000000",
            email: nil
        )
        #expect(result == .url(label: "Book a court", href: "https://book.me"))
    }

    @Test func prefersPhoneOverEmailWhenNoBookingUrl() {
        let result = getBookingAction(bookingUrl: "", phone: "0400000000", email: "a@b.com")
        if case .phone = result { } else { #expect(Bool(false), "Expected .phone, got \(result)") }
    }

    @Test func returnsNoneWhenAllContactOptionsAbsent() {
        let result = getBookingAction(bookingUrl: "", phone: nil, email: nil)
        #expect(result == .none)
    }
}
