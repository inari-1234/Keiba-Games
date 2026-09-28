import XCTest
@testable import KawaiiRace

final class ViewModelTests: XCTestCase {
    @MainActor func testRepeatedPurchaseBalanceAndSingleSettlement() throws {
        let model = RaceViewModel()
        try model.purchase(kind: .win, numbers: [3], stake: 100)
        try model.purchase(kind: .win, numbers: [3], stake: 500)
        XCTAssertEqual(model.balance, 11700)
        XCTAssertEqual(model.bets.count, 2)
        XCTAssertNotEqual(model.bets.first?.id, model.bets.last?.id)
        model.start(seed: 20260927)
        model.tick(seconds: 90)
        XCTAssertEqual(model.phase, .finished)
        XCTAssertEqual(model.totalPayout, 1680)
        XCTAssertEqual(model.net, 1080)
        XCTAssertEqual(model.balance, 13380)
        model.tick(seconds: 90)
        model.start()
        XCTAssertEqual(model.balance, 13380)
        XCTAssertEqual(model.settlements.count, 2)
    }
    @MainActor func testFailedPurchaseDoesNotMutateBalance() {
        let model = RaceViewModel()
        for amount in [0,99,12400] {
            XCTAssertThrowsError(try model.purchase(kind: .win, numbers: [3], stake: amount))
            XCTAssertEqual(model.balance, 12300)
            XCTAssertTrue(model.bets.isEmpty)
        }
        XCTAssertThrowsError(try model.purchase(kind: .quinella, numbers: [3,3], stake: 100))
        XCTAssertEqual(model.balance, 12300)
    }
    @MainActor func testExactBalancePurchaseAndClosedSales() throws {
        let model = RaceViewModel()
        try model.purchase(kind: .win, numbers: [3], stake: 12300)
        XCTAssertEqual(model.balance, 0)
        XCTAssertThrowsError(try model.purchase(kind: .win, numbers: [3], stake: 100))
        model.start(seed: 20260927)
        XCTAssertThrowsError(try model.purchase(kind: .win, numbers: [3], stake: 100)) { error in
            XCTAssertEqual(error as? BetError, .closed)
        }
        model.tick(seconds: 90)
        XCTAssertEqual(model.balance, 34440)
    }
    @MainActor func testNoBetRaceCompletes() {
        let model = RaceViewModel()
        model.start(seed: 20260927)
        model.tick(seconds: 20)
        XCTAssertEqual(model.phase, .racing)
        XCTAssertNil(model.result)
        model.tick(seconds: 70)
        XCTAssertEqual(model.phase, .finished)
        XCTAssertEqual(model.result?.finishes.count, 10)
        XCTAssertEqual(model.balance, 12300)
        XCTAssertEqual(model.totalPayout, 0)
        XCTAssertEqual(model.net, 0)
    }
    @MainActor func testAllSevenTicketsSettleTogether() throws {
        let model = RaceViewModel()
        let tickets: [(BetKind,[Int])] = [(.win,[3]),(.place,[6]),(.quinella,[3,6]),(.wide,[1,6]),(.exacta,[3,6]),(.trio,[1,3,6]),(.trifecta,[3,6,1])]
        for (kind,numbers) in tickets { try model.purchase(kind: kind, numbers: numbers, stake: 100) }
        XCTAssertEqual(model.balance, 11600)
        model.start(seed: 20260927)
        model.tick(seconds: 90)
        XCTAssertEqual(model.totalPayout, 13270)
        XCTAssertEqual(model.balance, 24870)
        XCTAssertEqual(model.settlements.count, 7)
        XCTAssertTrue(model.settlements.allSatisfy(\.hit))
    }
    @MainActor func testBetFormSelectionOrderAndReset() {
        let form = BetViewModel()
        form.kind = .trifecta
        form.select(3); form.select(6); form.select(1)
        XCTAssertEqual(form.numbers, [3,6,1])
        form.select(1)
        XCTAssertEqual(form.numbers, [3,6])
        form.kind = .wide
        XCTAssertTrue(form.numbers.isEmpty)
        form.add(500)
        XCTAssertEqual(form.amount, 600)
    }
    @MainActor func testReviewMatchesActualFinishers() throws {
        let model = RaceViewModel()
        model.start(seed: 20260927)
        model.tick(seconds: 90)
        let result = try XCTUnwrap(model.result)
        let review = RaceReview(race: model.race, result: result)
        XCTAssertEqual(review.topHorses.map(\.id), [3,6,1])
        XCTAssertEqual(review.summary, "ハイペースの展開となりました。先行馬のサクラノハナが好位から抜け出し、そのまま押し切りました。ラブリーショコラは外から鋭く伸びて2着。ハルノキセキも内から伸びて3着に入りました。")
        let alternate = RaceResult(finishes: [10,9,8,7,6,5,4,3,2,1].enumerated().map {
            HorseFinish(horseID: $0.element, rank: $0.offset + 1, time: Double(66 + $0.offset))
        }, pace: .low, seed: 9)
        let alternativeReview = RaceReview(race: model.race, result: alternate)
        XCTAssertEqual(alternativeReview.topHorses.map(\.id), [10,9,8])
        XCTAssertFalse(alternativeReview.summary.contains("サクラノハナ"))
        XCTAssertTrue(alternativeReview.summary.contains("落ち着いたペース"))
    }
}
