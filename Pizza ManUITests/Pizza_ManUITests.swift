import XCTest

final class Pizza_ManUITests: XCTestCase {

    @MainActor
    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    @MainActor
    func testTakeScreenshots() throws {
        let app = XCUIApplication()

        // Dismiss the iOS "Sign in to Game Center" banner if it appears.
        dismissGameCenterBanner()

        // Title / menu screen
        snapshot("01-Title")

        // Tap to start the game (the menu starts on tap)
        app.tap()
        sleep(2)
        dismissGameCenterBanner()
        snapshot("02-Gameplay")

        // Let some gameplay happen, then capture another moment
        sleep(3)
        dismissGameCenterBanner()
        snapshot("03-InAction")
    }

    @MainActor
    private func dismissGameCenterBanner() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let banner = springboard.otherElements["Sign in to Game Center"]
        if banner.waitForExistence(timeout: 1) {
            banner.swipeUp()
        }
    }
}
