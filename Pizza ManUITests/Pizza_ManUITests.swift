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
  func testLaunch() {
    let app = XCUIApplication()
    app.launch()
    XCTAssertEqual(app.state, .runningForeground)
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
