//
//  BingeWatchersTests.swift
//  BingeWatchersTests
//
//  Created by Anmol  Jandaur on 4/29/22.
//

import CoreData
import XCTest
@testable import BingeWatchers

class BaseTestCase: XCTestCase {
    // Our custom BaseTestCase subclass automatically creates a DataController instance before every test runs, so all our subsequent tests have access to data storage as needed.
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
