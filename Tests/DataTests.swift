import XCTest
@testable import KawaiiRace

final class DataTests: XCTestCase {
    func testTenUniqueCompleteEntrants() {
        let race = SampleRaceData.race
        XCTAssertNil(race.validate())
        XCTAssertEqual(race.horses.count, 10)
        XCTAssertEqual(Set(race.horses.map(\.id)), Set(1...10))
        XCTAssertEqual(Set(race.horses.map(\.popularity)), Set(1...10))
        for horse in race.horses {
            XCTAssertGreaterThan(horse.winOdds, 1)
            XCTAssertEqual(horse.recentResults.count, 4)
            XCTAssertFalse(horse.name.isEmpty)
            XCTAssertFalse(horse.jockey.name.isEmpty)
            XCTAssertEqual(BetEngine.odds(kind: .win, numbers: [horse.id]), horse.winOddsTenths)
        }
    }
    func testTipstersAndConditionMultipliers() {
        XCTAssertEqual(SampleRaceData.tipsters.count, 2)
        XCTAssertEqual(SampleRaceData.tipsters.first?.picks, [3,6,1])
        XCTAssertEqual(SampleRaceData.tipsters.last?.picks, [6,1,9])
        XCTAssertEqual(HorseCondition.up.multiplier, 1.04)
        XCTAssertEqual(HorseCondition.normal.multiplier, 1)
        XCTAssertEqual(HorseCondition.down.multiplier, 0.96)
    }
    func testAll1040FixedOddsAvailable() throws {
        var count = 0
        for kind in BetKind.allCases {
            for a in 1...10 {
                for b in 1...(kind.selectionCount >= 2 ? 10 : 1) {
                    for c in 1...(kind.selectionCount == 3 ? 10 : 1) {
                        let numbers = Array([a,b,c].prefix(kind.selectionCount))
                        guard Set(numbers).count == numbers.count else { continue }
                        guard kind.ordered || numbers == numbers.sorted() else { continue }
                        let ticket = try BetEngine.purchase(kind: kind, numbers: numbers, stake: 100, balance: 12300, horseIDs: Set(1...10))
                        XCTAssertGreaterThan(ticket.oddsTenths, 10)
                        count += 1
                    }
                }
            }
        }
        XCTAssertEqual(count, 1040)
        XCTAssertEqual(FixedOdds.values.count, 1040)
    }
}
