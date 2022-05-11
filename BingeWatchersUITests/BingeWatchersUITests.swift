//
//  BingeWatchersUITests.swift
//  BingeWatchersUITests
//
//  Created by Anmol  Jandaur on 5/10/22.
//

import XCTest

class BingeWatchersUITests: XCTestCase {
    
    // works best as an implicitly unwrapped optional because it will be created immediately and never be destroyed before an assertion is made
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app = XCUIApplication()
        
        app.launchArguments = ["enable-testing"]
        
        app.launch()
        
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testOpenTabAddsProjecs() {
        // using app.buttons["Open"].tap() looks for a button named “Open” on the screen and taps it
        app.buttons["Open"].tap()
        // app.tables.cells.count will attempt to locate a table (List, in SwiftUI) on the screen, and count how many rows it has
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")
        
        for tapCount in 1...5 {
            app.buttons["add"].tap()
            XCTAssertEqual(app.tables.cells.count, tapCount, "There should be \(tapCount) rows(s) in the list.")
            
        }
    }
    
    func testAddingItemInsertsRows() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")
        
        app.buttons["add"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")
        
        app.buttons["Add New Item"].tap()
        XCTAssertEqual(app.tables.cells.count, 2, "There should be 2 list rows after adding an item.")
    }
    
    func testEditingProjectUpdatesCorrectly() {
        app.buttons["Open"].tap()
        XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially")
        
        app.buttons["add"].tap()
        XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")
        
        // select the project
        app.buttons["NEW PROJECT"].tap()
        //' Edit the name text field
        app.textFields["Project name"].tap()
        
        //  The only guaranteed way to accurately type is to press individual keys manually, including switching between alphabetic and numeric keyboards by pressing what’s called the “more” button on the keyboard.
        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.keys["Return"].tap()
        
        // now that we’ve made the change we want to test, we can return back to ProjectsView and assert that a button named “NEW PROJECT 2” exists.
        app.buttons["Open Projects"].tap()
        
        XCTAssertTrue(app.buttons["NEW PROJECT 2"].exists, "The new project name should be visible in the list.")
    }
    
    func testEditingItemUpdatesCorrectly() {
        // OGo to Open Projects and add one project and one item.
        testAddingItemInsertsRows()
        
        app.buttons["New Item"].tap()
        
        app.textFields["Item name"].tap()
        app.keys["space"].tap()
        app.keys["more"].tap()
        app.keys["2"].tap()
        app.buttons["Return"].tap()
        
        app.buttons["Open Projects"].tap()
        
        XCTAssertTrue(app.buttons["New Item 2"].exists, "The new item name should be visible in the list.")
    }
    
    func testAllAwardsShowLockedAlert() {
        app.buttons["Awards"].tap()
        // uses app.scrollViews.buttons to look for the first scroll view and read buttons from there.
        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            // Once it has the buttons, it uses allElementsBoundByIndex to get an array of them all that we can loop over
            award.tap()
            XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
            app.buttons["OK"].tap()
        }
    }

    func testAppHas4Tabs() throws {
        // UI tests must launch the application that they test.
      
        XCTAssertEqual(app.tabBars.buttons.count, 4, "There should be 4 tabs in the app.")

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

}
