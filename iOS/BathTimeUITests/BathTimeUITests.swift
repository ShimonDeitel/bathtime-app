import XCTest

final class BathTimeUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddEntryFlow() {
        app.buttons["addButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("UI Test Entry")
        app.buttons["saveEntryButton"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 2))
    }

    func testFreeLimitTriggersPaywall() {
        for i in 0..<40 {
            app.buttons["addButton"].tap()
            let titleField = app.textFields["titleField"]
            if titleField.waitForExistence(timeout: 1) {
                titleField.tap()
                titleField.typeText("Entry \(i)")
                app.buttons["saveEntryButton"].tap()
            }
            if app.buttons["purchaseButton"].waitForExistence(timeout: 1) {
                break
            }
        }
        XCTAssertTrue(app.buttons["purchaseButton"].waitForExistence(timeout: 2))
    }

    func testKeyboardDismissOnTapOutside() {
        app.buttons["addButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Dismiss test")
        XCTAssertTrue(app.keyboards.element.exists)
        app.staticTexts.firstMatch.tap()
        XCTAssertFalse(app.keyboards.element.exists)
    }

    func testSettingsSheetOpens() {
        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 2))
        app.buttons["settingsDoneButton"].tap()
    }

    func testCancelAddDismissesSheet() {
        app.buttons["addButton"].tap()
        XCTAssertTrue(app.buttons["cancelAddButton"].waitForExistence(timeout: 2))
        app.buttons["cancelAddButton"].tap()
        XCTAssertFalse(app.textFields["titleField"].exists)
    }
}
