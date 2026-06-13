import Testing
@testable import Smash

struct PricingTests {
    @Test func formatsWholeDollarAmountsWithoutDecimal() {
        #expect(formatPriceCents(2900) == "$29/hr")
    }

    @Test func formatsRoundHundreds() {
        #expect(formatPriceCents(3600) == "$36/hr")
    }

    @Test func returnsCanonicalPhraseForNil() {
        #expect(formatPriceCents(nil) == "Rates not listed")
    }

    @Test func formatsZero() {
        #expect(formatPriceCents(0) == "$0/hr")
    }

    @Test func roundsHalfUp() {
        // 2150 cents = $21.50 → rounds to $22
        #expect(formatPriceCents(2150) == "$22/hr")
    }
}
