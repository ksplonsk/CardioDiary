//
//  CardioDiaryUITests.swift
//  CardioDiaryUITests
//
//  Created by Kristen Splonskowski on 2/27/17.
//  Copyright © 2017 Kristen Splonskowski. All rights reserved.
//

import XCTest

class CardioDiaryUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
		
		// setup environment flag to indicate UI testing
        let app = XCUIApplication()
		app.launchEnvironment["uitesting"] = "yes"
		app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCardioDiary() {
		let app = XCUIApplication()
		
		// wait until home screen is there
		let homeScreenNavBar = app.navigationBars["Cardio Diary"]
		let existsPredicate = NSPredicate(format: "exists == TRUE")
		expectation(for: existsPredicate, evaluatedWith: homeScreenNavBar, handler: nil)
		waitForExpectations(timeout: 5.0, handler: nil)
		
		// test entering a username
		let welcomeAlert = XCUIApplication().alerts["Welcome"]
		welcomeAlert.collectionViews.textFields["Your Name"].typeText("Kristen")
		welcomeAlert.buttons["OK"].tap()
		
		// test welcome message on homescreen
		let welcomeMessage = app.staticTexts.element(matching: .any, identifier: "welcome").label
		XCTAssertEqual(welcomeMessage, "Welcome, Kristen", "welcome message not correct")
		
		// test entering a goal
		app.buttons["Goals"].tap()
		
		let goalEntry = app.textFields.element(matching: .any, identifier: "goalEntry")
		goalEntry.tap()
		let deleteString = String(repeating: XCUIKeyboardKeyDelete, count: 8)
		goalEntry.typeText(deleteString)
		goalEntry.typeText("12")
		app.navigationBars["Goals"].buttons["Cardio Diary"].tap()
		
		Thread.sleep(forTimeInterval: 2)
		
		// test goal message on homescreen
		let goal = app.staticTexts.element(matching: .any, identifier: "goals").label
		XCTAssertNotEqual(goal, "Tap the Goals button to set a weekly goal", "goal message not persisted")
		
		// test recording a cardio entry
		app.buttons["Start Workout"].tap() // start workout button on homescreen
		app.buttons["Start Workout"].tap() // start workout button on record cardio screen
		Thread.sleep(forTimeInterval: 10)
		app.buttons["End Workout"].tap()
		
		app.buttons["Check Heart Rate"].tap()
		Thread.sleep(forTimeInterval: 14) // allow heart rate timer to run
		let heartRateAlert = app.alerts["Heart Rate"]
		let numberOfBeatsTextField = heartRateAlert.collectionViews.textFields["Number of Beats"]
		numberOfBeatsTextField.typeText("12")
		heartRateAlert.buttons["OK"].tap()
		app.toolbars.buttons["Done"].tap()
		
		// test workout message on homescreen updated after workout
		let workoutMessage = app.staticTexts.element(matching: .any, identifier: "workout").label
		XCTAssertNotEqual(workoutMessage, "Tap the Start Workout button to do your first workout", "workout message not correct")
		
		// test navigating to details screen
		app.buttons["Cardio History"].tap()
		app.tables.cells.element(boundBy: 0).tap() // first cell is most recent cardio event

		// test duration label on details screen is correct
		let durationLabel = app.staticTexts.element(matching: .any, identifier: "duration").label
		XCTAssertEqual(durationLabel, "0m 10s", "duration not correct")
		
		// test heart rate label on details screen is correct
		let heartRateLabel = app.staticTexts.element(matching: .any, identifier: "heartRate").label
		XCTAssertEqual(heartRateLabel, "72 beats per minute", "heart rate not correct")
    }
    
}
