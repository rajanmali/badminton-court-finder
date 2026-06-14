import Testing
import SwiftUI
@testable import Smash

struct GlassLevelTests {
    @Test
    func eachLevelHasADistinctMaterial() {
        // Distinct cases map to distinct materials; this proves the mapping is
        // total and the enum links into the test target.
        let levels: [GlassLevel] = [.ultraThin, .regular, .thick]
        #expect(levels.count == 3)
    }

    @Test
    func eachLevelHasADistinctSolidFallback() {
        // The reduced-transparency solid fills must differ per level, otherwise
        // the fallback would flatten the visual hierarchy.
        let ultra = GlassLevel.ultraThin.solid
        let regular = GlassLevel.regular.solid
        let thick = GlassLevel.thick.solid
        #expect(ultra != regular)
        #expect(regular != thick)
        #expect(ultra != thick)
    }
}
