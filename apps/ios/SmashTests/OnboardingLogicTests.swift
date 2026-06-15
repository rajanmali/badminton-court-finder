import Testing
@testable import Smash

// MARK: - Onboarding logic tests

/// Exercises ``defaultSort(forLocationAvailable:)`` — the location-aware
/// preselect for the onboarding sort step.
struct OnboardingLogicTests {

    @Test func locationAvailablePreselectsNearest() {
        #expect(defaultSort(forLocationAvailable: true) == .nearest)
    }

    @Test func noLocationPreselectsPriceLowToHigh() {
        #expect(defaultSort(forLocationAvailable: false) == .priceLowToHigh)
    }
}
