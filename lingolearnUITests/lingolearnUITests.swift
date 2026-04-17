import XCTest

final class lingolearnUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testFiveTabsExist() throws {
        let app = XCUIApplication()
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10))

        XCTAssertTrue(tabBar.buttons["首页"].exists)
        XCTAssertTrue(tabBar.buttons["学习"].exists)
        XCTAssertTrue(tabBar.buttons["练习"].exists)
        XCTAssertTrue(tabBar.buttons["进度"].exists)
        XCTAssertTrue(tabBar.buttons["设置"].exists)
    }

    @MainActor
    func testStartLearningButton_isPresent() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["开始学习"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testSettingsTab_opensAndShowsGoal() throws {
        let app = XCUIApplication()
        app.launch()

        let tab = app.tabBars.firstMatch.buttons["设置"]
        XCTAssertTrue(tab.waitForExistence(timeout: 10))
        tab.tap()
        XCTAssertTrue(app.staticTexts["每日学习目标"].waitForExistence(timeout: 5))
    }
}
