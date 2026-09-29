import XCTest
@testable import KeibaCore

final class RaceEngineTests: XCTestCase {
    private let race = SampleRaceData.race

    func testDebugSeedMatchesReferenceOrder() throws {
        let sim = try RaceEngine.simulate(race: race, seed: RaceEngine.debugSeed)
        XCTAssertEqual(Array(sim.finishOrder.prefix(5)), [3, 6, 1, 8, 5])
    }

    func testSameSeedGivesSameResult() throws {
        let a = try RaceEngine.simulate(race: race, seed: 42)
        let b = try RaceEngine.simulate(race: race, seed: 42)
        XCTAssertEqual(a.finishOrder, b.finishOrder)
        XCTAssertEqual(a.frames, b.frames)
    }

    func testDifferentSeedsChangeResult() throws {
        var orders = Set<[Int]>()
        var winners = Set<Int>()
        for seed in UInt64(1)...50 {
            let sim = try RaceEngine.simulate(race: race, seed: seed, recordFrames: false)
            orders.insert(sim.finishOrder)
            winners.insert(sim.finishOrder[0])
        }
        XCTAssertGreaterThan(orders.count, 40)
        XCTAssertGreaterThanOrEqual(winners.count, 3)
    }

    func testAllHorsesFinishWithoutTies() throws {
        for seed in UInt64(1)...200 {
            let sim = try RaceEngine.simulate(race: race, seed: seed, recordFrames: false)
            XCTAssertEqual(sim.finishOrder.count, 10)
            XCTAssertEqual(Set(sim.finishOrder).count, 10)
            let times = sim.finishTimes.values
            XCTAssertEqual(times.count, 10)
            XCTAssertEqual(Set(times).count, 10, "同着が発生 seed=\(seed)")
            for time in times {
                XCTAssertTrue(time.isFinite)
                XCTAssertGreaterThan(time, 0)
            }
        }
    }

    func testFramesHaveNoNaNAndProgressNeverDecreases() throws {
        for seed in [RaceEngine.debugSeed, 1, 7, 99_999] {
            let sim = try RaceEngine.simulate(race: race, seed: seed)
            XCTAssertGreaterThan(sim.frames.count, 2)
            var previous = [Double](repeating: 0, count: 10)
            for frame in sim.frames {
                XCTAssertEqual(frame.count, 10)
                for i in 0..<10 {
                    XCTAssertFalse(frame[i].isNaN)
                    XCTAssertTrue(frame[i].isFinite)
                    XCTAssertGreaterThanOrEqual(frame[i], previous[i])
                }
                previous = frame
            }
            XCTAssertTrue(previous.allSatisfy { $0 >= 1.0 }, "最終フレームで全馬がゴール済み")
        }
    }

    func testRaceDurationFitsSixtyToNinetySeconds() throws {
        for seed in UInt64(1)...100 {
            let sim = try RaceEngine.simulate(race: race, seed: seed, recordFrames: false)
            let times = Array(sim.finishTimes.values)
            XCTAssertGreaterThanOrEqual(times.min() ?? 0, 60)
            XCTAssertLessThanOrEqual(times.max() ?? 999, 90)
        }
    }

    func testFieldPaceIsHigh() {
        XCTAssertEqual(RaceEngine.pace(for: race.horses), .high)
    }

    func testEarlyFormationFollowsRunningStyle() throws {
        let sim = try RaceEngine.simulate(race: race, seed: RaceEngine.debugSeed)
        guard let frame = sim.frames.first(where: { ($0.max() ?? 0) >= 0.3 }) else {
            return XCTFail("序盤フレームが見つからない")
        }
        let ranked = sim.horseNumbers.indices.sorted { frame[$0] > frame[$1] }.map { sim.horseNumbers[$0] }
        let rank = { (number: Int) -> Int in (ranked.firstIndex(of: number) ?? 99) + 1 }
        XCTAssertLessThanOrEqual(rank(7), 2, "逃げ馬テンノオトメは1〜2番手")
        XCTAssertGreaterThanOrEqual(rank(4), 7, "追込コスモドリームは後方")
        XCTAssertGreaterThanOrEqual(rank(9), 7, "追込ニシノフラワーは後方")
    }

    func testPositionsChangeDuringRace() throws {
        let sim = try RaceEngine.simulate(race: race, seed: RaceEngine.debugSeed)
        var changes = 0
        var previous: [Int] = []
        for frame in sim.frames.dropFirst() {
            let ranked = sim.horseNumbers.indices.sorted { frame[$0] > frame[$1] }
            if !previous.isEmpty && ranked != previous { changes += 1 }
            previous = ranked
        }
        XCTAssertGreaterThanOrEqual(changes, 10)
    }

    func testInvalidFieldSizeThrows() {
        let short = Race(name: "x", grade: "", surface: "芝", distance: 1600, direction: "", going: "",
                         postTime: "", horses: Array(race.horses.prefix(9)), salt: 1)
        XCTAssertThrowsError(try RaceEngine.simulate(race: short, seed: 1)) { error in
            XCTAssertEqual(error as? RaceEngineError, .invalidFieldSize(9))
        }
    }
}
