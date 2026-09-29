import XCTest
@testable import KeibaCore

final class DataTests: XCTestCase {
    private let race = SampleRaceData.race

    func testFieldHasTenHorses() {
        XCTAssertEqual(race.horses.count, 10)
    }

    func testHorseNumbersAreUnique() {
        XCTAssertEqual(Set(race.horses.map(\.number)), Set(1...10))
    }

    func testPopularityIsOneToTenWithoutDuplicates() {
        XCTAssertEqual(Set(race.horses.map(\.popularity)), Set(1...10))
    }

    func testWinOddsAboveOne() {
        for horse in race.horses {
            XCTAssertGreaterThan(horse.winOddsTenths, 10, horse.name)
        }
    }

    func testRecentFinishesHaveFourEntries() {
        for horse in race.horses {
            XCTAssertEqual(horse.recentFinishes.count, 4, horse.name)
        }
    }

    func testPopularityMatchesOddsOrder() {
        let byOdds = race.horses.sorted { $0.winOddsTenths < $1.winOddsTenths }.map(\.popularity)
        XCTAssertEqual(byOdds, Array(1...10))
    }

    func testTipstersPickValidHorses() {
        XCTAssertEqual(SampleRaceData.tipsters.count, 2)
        for tipster in SampleRaceData.tipsters {
            XCTAssertEqual(tipster.picks.count, 3)
            for pick in tipster.picks {
                XCTAssertNotNil(race.horse(number: pick.horseNumber))
            }
        }
    }

    func testInitialBalance() {
        XCTAssertEqual(SampleRaceData.initialBalance, 12_300)
    }
}
