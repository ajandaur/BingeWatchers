//
//  ProjectTests.swift
//  BingeWatchersTests
//
//  Created by Anmol  Jandaur on 4/30/22.
//

import XCTest
import CoreData
@testable import BingeWatchers

class ProjectTests: BaseTestCase {
    func testCreatingProjectsAndItems() {
        let targetCount = 10
        
        for _ in 0..<targetCount {
            let project = Project(context: managedObjectContext)
            
            for _ in 0..<targetCount {
                let item = Item(context: managedObjectContext)
                item.project = project
            }
        }
        
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), targetCount)
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), targetCount * targetCount)
        
    }
    
    func testDeletingProjectCascadeDeleteItems() throws {
        try dataController.createSampleData()
        
        let request = NSFetchRequest<Project>(entityName: "Project")
        let projects = try managedObjectContext.fetch(request)
        
        dataController.delete(projects[0])
        
        XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 4)
        XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 40)
    }
}
