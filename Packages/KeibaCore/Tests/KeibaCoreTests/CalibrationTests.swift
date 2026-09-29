import XCTest
@testable import KeibaCore

/// 仕様追補 v1.0.1: 1万レースの勝率が単勝オッズの示す確率に近いこと（必勝法を作らない）
final class CalibrationTests: XCTestCase {
    func testWinRatesMatchOddsImpliedProbabilities() throws {
        let race = SampleRaceData.race
        let inverse = race.horses.map { 10.0 / Double($0.winOddsTenths) }
        let total = inverse.reduce(0, +)
        var implied: [Int: Double] = [:]
        for (horse, inv) in zip(race.horses, inverse) { implied[horse.number] = inv / total }

        let runs = 10_000
        var wins: [Int: Int] = [:]
        for seed in UInt64(1)...UInt64(runs) {
            let sim = try RaceEngine.simulate(race: race, seed: seed, recordFrames: false)
            wins[sim.finishOrder[0], default: 0] += 1
        }
        for horse in race.horses {
            let expected = implied[horse.number] ?? 0
            let actual = Double(wins[horse.number] ?? 0) / Double(runs)
            let tolerance = max(0.015, 0.2 * expected)
            XCTAssertEqual(actual, expected, accuracy: tolerance, "\(horse.number) \(horse.name)")
        }
        // 10番人気が高確率で勝たない（仕様24）
        XCTAssertLessThan(Double(wins[10] ?? 0) / Double(runs), 0.05)
    }
}
