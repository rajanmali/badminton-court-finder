import Testing
@testable import Smash

struct SmashScaffoldTests {
    @Test
    func scaffoldBuildsAndRuns() {
        // Trivial assertion proving the test target builds and runs in CI.
        #expect(true)
    }

    @Test
    func designTokensAreAvailable() {
        // Proves the app module is importable and design tokens link.
        #expect(Spacing.md == 16)
        #expect(Typography.Size.xxl == 24)
    }
}
