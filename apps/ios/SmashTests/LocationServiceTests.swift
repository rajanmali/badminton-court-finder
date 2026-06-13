import Testing
@testable import Smash

// MARK: - Fixtures

private let SYDNEY_CBD = UserCoords(latitude: -33.8688, longitude: 151.2093)
private let PARRAMATTA = UserCoords(latitude: -33.8150, longitude: 151.0011)

// MARK: - MockLocationService

struct MockLocationServiceTests {
    @Test func returnsLocatedOutcome() async {
        let mock = MockLocationService(outcome: .located(SYDNEY_CBD))
        let result = await mock.requestLocation()
        #expect(result == .located(SYDNEY_CBD))
    }

    @Test func returnsDeniedOutcome() async {
        let mock = MockLocationService(outcome: .denied)
        let result = await mock.requestLocation()
        #expect(result == .denied)
    }

    @Test func returnsUnavailableOutcome() async {
        let mock = MockLocationService(outcome: .unavailable)
        let result = await mock.requestLocation()
        #expect(result == .unavailable)
    }
}

// MARK: - LocationOutcome → (coords, permissionDenied) mapping

struct LocationOutcomeMappingTests {
    @Test func locatedMapsToCoordsAndNotDenied() {
        let state = LocationOutcome.located(SYDNEY_CBD).locationState
        #expect(state.coords == SYDNEY_CBD)
        #expect(state.permissionDenied == false)
    }

    @Test func deniedMapsToNilCoordsAndDenied() {
        let state = LocationOutcome.denied.locationState
        #expect(state.coords == nil)
        #expect(state.permissionDenied == true)
    }

    @Test func unavailableMapsToNilCoordsAndNotDenied() {
        let state = LocationOutcome.unavailable.locationState
        #expect(state.coords == nil)
        #expect(state.permissionDenied == false)
    }
}

// MARK: - LocationOutcome Equatable

struct LocationOutcomeEquatableTests {
    @Test func sameLocatedCoordsAreEqual() {
        #expect(LocationOutcome.located(SYDNEY_CBD) == .located(SYDNEY_CBD))
    }

    @Test func differentLocatedCoordsAreNotEqual() {
        #expect(LocationOutcome.located(SYDNEY_CBD) != .located(PARRAMATTA))
    }

    @Test func locatedIsNotEqualToDenied() {
        #expect(LocationOutcome.located(SYDNEY_CBD) != .denied)
    }

    @Test func deniedIsNotEqualToUnavailable() {
        #expect(LocationOutcome.denied != .unavailable)
    }

    @Test func deniedEqualsDenied() {
        #expect(LocationOutcome.denied == .denied)
    }
}
