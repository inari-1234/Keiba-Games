import XCTest
@testable import KeibaCore

final class PlayerProgressTests: XCTestCase {
    func testTitles() {
        XCTAssertEqual(PlayerTitle.title(for: 0), .apprentice)
        XCTAssertEqual(PlayerTitle.title(for: 12_300), .apprentice)
        XCTAssertEqual(PlayerTitle.title(for: 20_000), .regular)
        XCTAssertEqual(PlayerTitle.title(for: 50_000), .skilled)
        XCTAssertEqual(PlayerTitle.title(for: 199_999), .skilled)
        XCTAssertEqual(PlayerTitle.title(for: 200_000), .master)
        XCTAssertEqual(PlayerTitle.title(for: 5_000_000), .legend)
    }

    func testRescueOnlyWhenBrokeAndNoOpenBets() {
        XCTAssertTrue(RescuePolicy.canRestart(balance: 0, hasOpenBets: false))
        XCTAssertTrue(RescuePolicy.canRestart(balance: 90, hasOpenBets: false))
        XCTAssertFalse(RescuePolicy.canRestart(balance: 100, hasOpenBets: false))
        XCTAssertFalse(RescuePolicy.canRestart(balance: 0, hasOpenBets: true))
        XCTAssertEqual(RescuePolicy.restartBalance, 12_300)
    }
}
