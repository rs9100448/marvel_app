//
//  DetailNavigationUITests.swift
//  MarvelAppUITests
//
//  Verifies detail-screen navigation: the custom back button is present and the
//  interactive swipe-back gesture returns to Home.
//

import XCTest

final class DetailNavigationUITests: XCTestCase {

    private func launchedApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uitestAuthed"]
        app.launch()
        return app
    }

    func testDetailHasBackButtonAndSwipeReturnsHome() {
        let app = launchedApp()

        // Home is shown (seeded authed launch).
        let homeMarker = app.staticTexts["Latest Movies"]
        XCTAssertTrue(homeMarker.waitForExistence(timeout: 10), "Home did not appear")

        // Open a title detail by tapping the first featured poster.
        let poster = app.buttons["Avengers: Age of Ultron"].firstMatch
        XCTAssertTrue(poster.waitForExistence(timeout: 5), "Featured poster not found")
        poster.tap()

        // The custom back button exists (proves the toolbar back item is wired).
        let backButton = app.buttons["Back"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Detail back button missing")

        // Interactive swipe-from-left-edge should pop back to Home.
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.5))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: end)

        XCTAssertTrue(homeMarker.waitForExistence(timeout: 5),
                      "Swipe-back gesture did not return to Home")

        // Capture the result for the record.
        let shot = XCTAttachment(screenshot: app.screenshot())
        shot.lifetime = .keepAlways
        add(shot)
    }

    func testBackButtonTapReturnsHome() {
        let app = launchedApp()
        XCTAssertTrue(app.staticTexts["Latest Movies"].waitForExistence(timeout: 10))

        app.buttons["Avengers: Age of Ultron"].firstMatch.tap()
        let backButton = app.buttons["Back"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()

        XCTAssertTrue(app.staticTexts["Latest Movies"].waitForExistence(timeout: 5),
                      "Tapping back did not return to Home")
    }
}
