import XCTest
@testable import KawaiiRace

final class RaceEngineTests: XCTestCase {
    private func complete(seed: UInt64, interval: Double = 0.05) throws -> RaceEngine {
        var engine = try RaceEngine(race: SampleRaceData.race, seed: seed)
        while engine.isFinished == false && engine.elapsed < 90 { engine.advance(seconds: interval) }
        return engine
    }
    func testReferenceSeedAndReproducibility() throws {
        let first = try complete(seed: 20260927)
        let second = try complete(seed: 20260927)
        XCTAssertEqual(first.result?.order.prefix(5).map { $0 }, [3,6,1,8,5])
        XCTAssertEqual(first.result, second.result)
        XCTAssertEqual(first.pace, .high)
        XCTAssertTrue((60...90).contains(first.elapsed))
    }
    func testPlaybackIntervalsDoNotChangeResult() throws {
        let normal = try complete(seed: 20260927)
        let doubleSpeed = try complete(seed: 20260927, interval: 0.1)
        let irregular = try complete(seed: 20260927, interval: 0.137)
        XCTAssertEqual(normal.result, doubleSpeed.result)
        XCTAssertEqual(normal.result, irregular.result)
    }
    func test100SeedsFinishWithoutNaNOrBackwardProgress() throws {
        var orders = Set<[Int]>()
        var outsiderWins = 0
        for seed in UInt64(0)..<100 {
            var engine = try RaceEngine(race: SampleRaceData.race, seed: seed)
            var previous = Dictionary(uniqueKeysWithValues: engine.runners.map { ($0.id, 0.0) })
            var liveOrders = Set<[Int]>()
            while engine.isFinished == false && engine.elapsed < 90 {
                engine.advance(seconds: 0.1)
                for runner in engine.runners {
                    XCTAssertTrue(runner.raceProgress.isFinite)
                    XCTAssertTrue(runner.velocity.isFinite)
                    XCTAssertGreaterThanOrEqual(runner.raceProgress, previous[runner.id] ?? 0)
                    XCTAssertTrue((0.96...1.04).contains(runner.performance))
                    previous[runner.id] = runner.raceProgress
                }
                liveOrders.insert(engine.standings.map(\.id))
            }
            let result = try XCTUnwrap(engine.result)
            XCTAssertEqual(Set(result.finishes.map(\.rank)), Set(1...10))
            XCTAssertEqual(Set(result.order), Set(1...10))
            XCTAssertTrue(result.finishes.allSatisfy { $0.time.isFinite && $0.time > 0 })
            XCTAssertTrue((60...90).contains(engine.elapsed))
            XCTAssertGreaterThan(liveOrders.count, 2)
            orders.insert(result.order)
            if result.order.first == 10 { outsiderWins += 1 }
        }
        XCTAssertGreaterThan(orders.count, 1)
        XCTAssertLessThan(outsiderWins, 10)
    }
    func testInvalidAdvanceIsHarmlessAndFinishIsStable() throws {
        var engine = try RaceEngine(race: SampleRaceData.race, seed: 20260927)
        engine.advance(seconds: .nan)
        engine.advance(seconds: .infinity)
        engine.advance(seconds: -1)
        XCTAssertEqual(engine.elapsed, 0)
        engine.advance(seconds: 90)
        let result = engine.result
        engine.advance(seconds: 90)
        XCTAssertEqual(result, engine.result)
    }
    func testMissingDataRejected() {
        let original = SampleRaceData.race
        let bad = Race(name: original.name, grade: original.grade, distance: 1600, direction: original.direction,
                       surface: original.surface, going: original.going, startTime: original.startTime,
                       horses: Array(original.horses.dropLast()))
        XCTAssertThrowsError(try RaceEngine(race: bad, seed: 1))
    }
    func testJockeyDoesNotAffectResult() throws {
        let original = SampleRaceData.race
        let horses = original.horses.map { h in
            Horse(id: h.id, frame: h.frame, name: h.name, jockey: Jockey(name: "別の騎手", silkHex: 0, capHex: 0),
                  popularity: h.popularity, winOddsTenths: h.winOddsTenths, style: h.style,
                  condition: h.condition, recentResults: h.recentResults, comment: h.comment, coatHex: h.coatHex, ability: h.ability)
        }
        let other = Race(name: original.name, grade: original.grade, distance: original.distance, direction: original.direction,
                         surface: original.surface, going: original.going, startTime: original.startTime, horses: horses)
        var changed = try RaceEngine(race: other, seed: 20260927)
        changed.advance(seconds: 90)
        XCTAssertEqual(changed.result, try complete(seed: 20260927).result)
    }
}
