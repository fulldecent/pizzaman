import XCTest

final class Pizza_ManUITests: XCTestCase {

  @MainActor
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  @MainActor
  func testLaunch() {
    let app = XCUIApplication()
    // SnapshotHelper only adds this flag when its cache directory exists.
    // The GitHub simulator does not have that directory, so set it here.
    // AppDelegate skips Game Center authentication when the flag is present.
    app.launchArguments += ["-FASTLANE_SNAPSHOT", "YES"]
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
