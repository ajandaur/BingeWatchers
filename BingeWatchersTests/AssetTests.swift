//
//  AssetTests.swift
//  BingeWatchersTests
//
//  Created by Anmol  Jandaur on 4/29/22.
//

import XCTest
@testable import BingeWatchers

// we’re going to write tests to ensure two items from our app bundle exist: all the colors we expect, and our awards JSON
class AssetTests: XCTestCase {
    
    func testColorsExist() {
        for color in Project.colors {
            XCTAssertNotNil(UIColor(named: color), "Failed to load '\(color)' from asset catalog.")
        }
    }
    
    func testJSONLoadsCorrectly() {
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON.")
    }
}
