import Testing
@testable import Smash

// MARK: - View mode wiring

/// Confirms the `VenueListModel.viewMode` wiring compiles and its default
/// matches RN's initial `useState('list')`. The map view itself (a
/// UIViewRepresentable over a binary framework) is verified at the parity gate,
/// not in unit tests.
@MainActor
struct ViewModeTests {

    @Test func defaultsToList() {
        let model = VenueListModel()
        #expect(model.viewMode == .list)
    }

    @Test func switchingToMapSticks() {
        let model = VenueListModel()
        model.viewMode = .map
        #expect(model.viewMode == .map)
    }
}
