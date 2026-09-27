import XCTest

final class NavigationTests: XCTestCase {
    @MainActor private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"]
        app.launch()
        XCTAssertTrue(app.buttons["horse.1"].waitForExistence(timeout: 20))
        return app
    }
    @MainActor private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    @MainActor private func reveal(_ element: XCUIElement, in scroll: XCUIElement, upwards: Bool = true) {
        for _ in 0..<12 {
            if element.exists && element.isHittable { return }
            if upwards { scroll.swipeUp() } else { scroll.swipeDown() }
        }
        XCTAssertTrue(element.isHittable, "Element should be visible: \(element)")
    }
    @MainActor func testCompleteRaceWithAllSevenTicketTypes() {
        continueAfterFailure = false
        let app = launch()
        capture("01-entries", app: app)
        app.buttons["horse.1"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["horse.detail.1"].exists)
        capture("02-horse-detail", app: app)
        app.buttons["horse.1"].tap()
        for number in 1...10 {
            reveal(app.buttons["horse.\(number)"], in: app.scrollViews["entries.scroll"])
        }
        capture("03-entries-last", app: app)
        app.segmentedControls.buttons["予想家の印"].tap()
        XCTAssertTrue(app.staticTexts["桜井ひなた"].exists)
        XCTAssertTrue(app.staticTexts["黒川レン"].exists)
        capture("04-tipsters", app: app)
        app.buttons["open.paddock"].tap()
        XCTAssertTrue(app.staticTexts["パドック"].waitForExistence(timeout: 10))
        capture("05-paddock", app: app)
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["ミルキースカイ"].waitForExistence(timeout: 5))
        for current in 2...9 { app.buttons["paddock.next.\(current)"].tap() }
        XCTAssertTrue(app.staticTexts["アオゾラチャーム"].exists)
        app.buttons["paddock.previous.10"].tap()
        XCTAssertTrue(app.staticTexts["ニシノフラワー"].exists)
        app.buttons["閉じる"].tap()
        app.segmentedControls.buttons["馬券購入"].tap()
        let tickets: [(String,[Int])] = [("単勝",[3]),("複勝",[6]),("馬連",[3,6]),("ワイド",[1,6]),("馬単",[3,6]),("三連複",[1,3,6]),("三連単",[3,6,1])]
        for (index, ticket) in tickets.enumerated() {
            let kind = app.buttons["bet.kind.\(ticket.0)"]
            let strip = app.scrollViews["bet.kinds"]
            for _ in 0..<4 {
                // Query hittability only after scrolling the entire tab into the viewport.
                // XCTest can throw instead of returning false for a fully clipped button.
                if kind.exists && app.frame.insetBy(dx: 12, dy: 0).contains(kind.frame) { break }
                strip.swipeLeft()
            }
            XCTAssertTrue(kind.isHittable)
            kind.tap()
            for number in ticket.1 { app.buttons["bet.horse.\(number)"].tap() }
            reveal(app.buttons["bet.purchase"], in: app.scrollViews["bet.form"])
            app.buttons["bet.purchase"].tap()
            let confirm = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "ptで購入")).firstMatch
            XCTAssertTrue(confirm.waitForExistence(timeout: 5))
            if index == 6 { capture("06-purchase-confirmation", app: app) }
            confirm.tap()
            XCTAssertTrue(app.staticTexts["bet.purchased"].waitForExistence(timeout: 5))
            let expected = 12300 - (index + 1) * 100
            XCTAssertEqual(app.staticTexts["header.balance"].label, "所持 \(expected.formatted())pt")
        }
        capture("07-purchased-tickets", app: app)
        let start = Date()
        app.buttons["race.start"].tap()
        XCTAssertTrue(app.staticTexts["race.commentary"].waitForExistence(timeout: 10))
        let runners = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "runner.")).allElementsBoundByIndex
        XCTAssertEqual(runners.count, 10)
        for runner in runners {
            XCTAssertFalse(runner.frame.isEmpty)
            XCTAssertTrue(app.frame.contains(runner.frame), "Runner stays in phone bounds")
        }
        capture("08-live-race", app: app)
        XCTAssertTrue(app.staticTexts["レース結果"].waitForExistence(timeout: 95))
        let duration = Date().timeIntervalSince(start)
        XCTAssertGreaterThanOrEqual(duration, 60)
        XCTAssertLessThanOrEqual(duration, 90)
        print("NORMAL_RACE_WALL_SECONDS=\(duration)")
        XCTAssertEqual(app.staticTexts["result.amount.払戻額"].label, "13,270pt")
        XCTAssertEqual(app.staticTexts["result.amount.所持ポイント"].label, "24,870pt")
        capture("09-result-and-payout", app: app)
        reveal(app.staticTexts["アオゾラチャーム"], in: app.scrollViews["result.scroll"])
        capture("10-results-last", app: app)
        reveal(app.staticTexts["レースの振り返り"], in: app.scrollViews["result.scroll"])
        capture("11-review", app: app)
        reveal(app.staticTexts["各馬のポイント"], in: app.scrollViews["result.scroll"])
        capture("12-review-points", app: app)
    }
    @MainActor func testNoPurchaseAndDoubleSpeed() {
        continueAfterFailure = false
        let app = launch()
        app.buttons["race.start"].tap()
        XCTAssertTrue(app.staticTexts["race.commentary"].waitForExistence(timeout: 10))
        let start = Date()
        app.segmentedControls.buttons["2倍速"].tap()
        XCTAssertTrue(app.staticTexts["レース結果"].waitForExistence(timeout: 55))
        XCTAssertLessThanOrEqual(Date().timeIntervalSince(start), 55)
        XCTAssertEqual(app.staticTexts["result.amount.購入額"].label, "0pt")
        XCTAssertEqual(app.staticTexts["result.amount.払戻額"].label, "0pt")
        XCTAssertEqual(app.staticTexts["result.amount.所持ポイント"].label, "12,300pt")
        capture("13-no-bet-result", app: app)
    }
}
