import XCTest
import KeibaCore

final class AppSmokeTests: XCTestCase {
    func testSampleRaceLoadsInApp() {
        XCTAssertEqual(SampleRaceData.race.horses.count, 10)
    }

    func testDebugBuildUsesFixedSeed() throws {
        let sim = try RaceEngine.simulate(race: SampleRaceData.race, seed: RaceEngine.debugSeed, recordFrames: false)
        XCTAssertEqual(Array(sim.finishOrder.prefix(5)), [3, 6, 1, 8, 5])
    }
}
