import XCTest
@testable import KeibaCore

final class BetEngineTests: XCTestCase {
    private let engine = BetEngine(race: SampleRaceData.race)
    private let order = [3, 6, 1, 8, 5, 7, 4, 10, 2, 9]

    private func check(_ type: BetType, hit: [Int], miss: [Int], amount: Int, expectedPayout: Int,
                       file: StaticString = #filePath, line: UInt = #line) throws {
        let hitSel = try engine.makeSelection(type: type, numbers: hit)
        let (hitBet, balance) = try engine.purchase(selection: hitSel, amount: amount, balance: 12_300)
        XCTAssertEqual(balance, 12_300 - amount, file: file, line: line)
        XCTAssertTrue(engine.isHit(hitSel, finishOrder: order), file: file, line: line)
        XCTAssertEqual(engine.payout(for: hitBet, finishOrder: order), expectedPayout, file: file, line: line)

        let missSel = try engine.makeSelection(type: type, numbers: miss)
        let (missBet, _) = try engine.purchase(selection: missSel, amount: amount, balance: 12_300)
        XCTAssertFalse(engine.isHit(missSel, finishOrder: order), file: file, line: line)
        XCTAssertEqual(engine.payout(for: missBet, finishOrder: order), 0, file: file, line: line)
    }

    func testWin() throws { try check(.win, hit: [3], miss: [6], amount: 100, expectedPayout: 280) }
    func testPlace() throws { try check(.place, hit: [1], miss: [8], amount: 100, expectedPayout: 170) }
    func testQuinella() throws { try check(.quinella, hit: [6, 3], miss: [3, 8], amount: 1_000, expectedPayout: 4_800) }
    func testWide() throws { try check(.wide, hit: [1, 6], miss: [3, 8], amount: 1_000, expectedPayout: 3_500) }
    func testExacta() throws { try check(.exacta, hit: [3, 6], miss: [6, 3], amount: 1_000, expectedPayout: 8_800) }
    func testTrio() throws { try check(.trio, hit: [6, 1, 3], miss: [3, 6, 8], amount: 1_000, expectedPayout: 6_400) }
    func testTrifecta() throws { try check(.trifecta, hit: [3, 6, 1], miss: [6, 3, 1], amount: 100, expectedPayout: 3_000) }

    func testUnorderedSelectionsAreNormalized() throws {
        let a = try engine.makeSelection(type: .quinella, numbers: [6, 3])
        let b = try engine.makeSelection(type: .quinella, numbers: [3, 6])
        XCTAssertEqual(a, b)
        let c = try engine.makeSelection(type: .exacta, numbers: [6, 3])
        XCTAssertEqual(c.numbers, [6, 3])
    }

    func testInvalidSelectionsAreRejected() {
        XCTAssertThrowsError(try engine.makeSelection(type: .quinella, numbers: [3])) {
            XCTAssertEqual($0 as? BetError, .wrongSelectionCount)
        }
        XCTAssertThrowsError(try engine.makeSelection(type: .win, numbers: [11])) {
            XCTAssertEqual($0 as? BetError, .unknownHorse)
        }
        XCTAssertThrowsError(try engine.makeSelection(type: .trio, numbers: [3, 3, 1])) {
            XCTAssertEqual($0 as? BetError, .duplicateHorse)
        }
    }

    func testBalanceRules() throws {
        let sel = try engine.makeSelection(type: .win, numbers: [3])
        XCTAssertNoThrow(try engine.purchase(selection: sel, amount: 12_200, balance: 12_300))
        XCTAssertNoThrow(try engine.purchase(selection: sel, amount: 12_300, balance: 12_300))
        XCTAssertThrowsError(try engine.purchase(selection: sel, amount: 12_400, balance: 12_300)) {
            XCTAssertEqual($0 as? BetError, .insufficientBalance)
        }
        XCTAssertThrowsError(try engine.purchase(selection: sel, amount: 0, balance: 12_300)) {
            XCTAssertEqual($0 as? BetError, .amountNotPositive)
        }
        XCTAssertThrowsError(try engine.purchase(selection: sel, amount: 50, balance: 12_300)) {
            XCTAssertEqual($0 as? BetError, .amountBelowMinimum)
        }
        XCTAssertThrowsError(try engine.purchase(selection: sel, amount: 150, balance: 12_300)) {
            XCTAssertEqual($0 as? BetError, .amountNotMultipleOfUnit)
        }
    }

    func testRepeatPurchaseOnSameSelectionPaysEach() throws {
        let sel = try engine.makeSelection(type: .win, numbers: [3])
        let first = try engine.purchase(selection: sel, amount: 100, balance: 12_300)
        let second = try engine.purchase(selection: sel, amount: 500, balance: first.newBalance)
        XCTAssertEqual(second.newBalance, 11_700)
        let settlement = engine.settle(bets: [first.bet, second.bet], finishOrder: order)
        XCTAssertEqual(settlement.totalStake, 600)
        XCTAssertEqual(settlement.totalPayout, 280 + 1_400)
        XCTAssertEqual(settlement.net, 1_080)
    }

    func testOddsTableIsComplete() {
        let table = OddsTable.generated
        XCTAssertEqual(table.count(for: .win), 10)
        XCTAssertEqual(table.count(for: .place), 10)
        XCTAssertEqual(table.count(for: .quinella), 45)
        XCTAssertEqual(table.count(for: .wide), 45)
        XCTAssertEqual(table.count(for: .exacta), 90)
        XCTAssertEqual(table.count(for: .trio), 120)
        XCTAssertEqual(table.count(for: .trifecta), 720)
    }

    func testWinOddsInTableMatchRaceCard() throws {
        for horse in SampleRaceData.race.horses {
            let sel = try engine.makeSelection(type: .win, numbers: [horse.number])
            XCTAssertEqual(engine.odds.tenths(for: sel), horse.winOddsTenths)
        }
    }
}
