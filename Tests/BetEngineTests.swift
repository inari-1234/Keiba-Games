import XCTest
@testable import KawaiiRace

final class BetEngineTests: XCTestCase {
    private let result = RaceResult(finishes: [3,6,1,8,5,2,9,4,7,10].enumerated().map {
        HorseFinish(horseID: $0.element, rank: $0.offset + 1, time: 66 + Double($0.offset))
    }, pace: .high, seed: 20260927)
    private func verify(_ kind: BetKind, winning: [Int], losing: [Int], payout: Int) throws {
        let ticket = try BetEngine.purchase(kind: kind, numbers: winning, stake: 100, balance: 12300, horseIDs: Set(1...10))
        let settlement = BetEngine.settle(ticket, result: result)
        XCTAssertEqual(ticket.stake, 100)
        XCTAssertTrue(settlement.hit)
        XCTAssertEqual(settlement.payout, payout)
        let miss = try BetEngine.purchase(kind: kind, numbers: losing, stake: 100, balance: 12300, horseIDs: Set(1...10))
        XCTAssertFalse(BetEngine.settle(miss, result: result).hit)
        XCTAssertEqual(BetEngine.settle(miss, result: result).payout, 0)
        XCTAssertThrowsError(try BetEngine.purchase(kind: kind, numbers: winning, stake: 0, balance: 12300, horseIDs: Set(1...10)))
    }
    func testWinPurchaseHitMissPayout() throws { try verify(.win, winning: [3], losing: [6], payout: 280) }
    func testPlacePurchaseHitMissPayout() throws { try verify(.place, winning: [1], losing: [8], payout: 210) }
    func testQuinellaPurchaseHitMissPayout() throws { try verify(.quinella, winning: [6,3], losing: [3,1], payout: 620) }
    func testWidePurchaseHitMissPayout() throws { try verify(.wide, winning: [1,6], losing: [3,8], payout: 410) }
    func testExactaPurchaseHitMissPayout() throws { try verify(.exacta, winning: [3,6], losing: [6,3], payout: 1240) }
    func testTrioPurchaseHitMissPayout() throws { try verify(.trio, winning: [6,1,3], losing: [3,6,8], payout: 1980) }
    func testTrifectaPurchaseHitMissPayout() throws { try verify(.trifecta, winning: [3,6,1], losing: [1,6,3], payout: 8560) }
    func testAllThreeWidePairsAndPlaceFinishers() throws {
        for (numbers, payout) in [([3,6],290),([1,3],340),([1,6],410)] {
            try verify(.wide, winning: numbers, losing: [9,10], payout: payout)
        }
        for (number, payout) in [(3,140),(6,180),(1,210)] {
            try verify(.place, winning: [number], losing: [8], payout: payout)
        }
    }
    func testAmountBoundaries() throws {
        for amount in [-100,0,1,99,101,12400] {
            XCTAssertThrowsError(try BetEngine.purchase(kind: .win, numbers: [3], stake: amount, balance: 12300, horseIDs: Set(1...10)))
        }
        XCTAssertEqual(try BetEngine.purchase(kind: .win, numbers: [3], stake: 12300, balance: 12300, horseIDs: Set(1...10)).stake, 12300)
        XCTAssertNoThrow(try BetEngine.purchase(kind: .win, numbers: [3], stake: 100, balance: 12300, horseIDs: Set(1...10)))
    }
    func testInvalidCombinationsRejectedForEveryKind() {
        for kind in BetKind.allCases {
            XCTAssertThrowsError(try BetEngine.purchase(kind: kind, numbers: [], stake: 100, balance: 12300, horseIDs: Set(1...10)))
            XCTAssertThrowsError(try BetEngine.purchase(kind: kind, numbers: Array(repeating: 11, count: kind.selectionCount), stake: 100, balance: 12300, horseIDs: Set(1...10)))
            if kind.selectionCount > 1 {
                XCTAssertThrowsError(try BetEngine.purchase(kind: kind, numbers: Array(repeating: 3, count: kind.selectionCount), stake: 100, balance: 12300, horseIDs: Set(1...10)))
            }
        }
    }
    func testPayoutUsesPurchasedOddsAndStake() throws {
        let ticket = try BetEngine.purchase(kind: .trifecta, numbers: [3,6,1], stake: 500, balance: 12300, horseIDs: Set(1...10))
        XCTAssertEqual(BetEngine.settle(ticket, result: result).payout, 42800)
    }
    func testInvalidResultPaysNothing() throws {
        let ticket = try BetEngine.purchase(kind: .win, numbers: [3], stake: 100, balance: 12300, horseIDs: Set(1...10))
        XCTAssertEqual(BetEngine.settle(ticket, result: RaceResult(finishes: [], pace: .high, seed: 1)).payout, 0)
    }
}
