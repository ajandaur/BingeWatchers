//
//  DataController.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 1/10/22.
//

import CoreData
import SwiftUI

// conform to ObservableObject so any SwiftUI view can watch this Controller for changes
class DataController: ObservableObject {
    // container for synchronizing the data with iCloud so that all a user’s devices get to share the same data for our app
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    // build a pre-made data controller suitable for previewing SwiftUI views
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        let viewContext = dataController.container.viewContext

        do {
            try dataController.createSampleData()
        } catch {
            fatalError("Fatal error creating preview: \(error.localizedDescription)")
        }

        return dataController
    }()
    
    func createSampleData() throws {
        let viewContext = container.viewContext

        for projectCounter in 1...5 {
            let project = Project(context: viewContext)
            project.title = "Project \(projectCounter)"
            project.items = []
            project.creationDate = Date()
            project.closed = Bool.random()

            for itemCounter in 1...10 {
                let item = Item(context: viewContext)
                item.title = "Item \(itemCounter)"
                item.creationDate = Date()
                item.completed = Bool.random()
                item.project = project
                item.priority = Int16.random(in: 1...3)
            }
        }

        try viewContext.save()
    }
    
    // only save when there are actually changes made
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    //  delete one specific project or item from our view context
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
    }
    
    // method to wipe out all projects and items in our database
    func deleteAll() {
        // Need FetchRequest to find all items
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        // wrap FetchRequest in batch delete request
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        // execute batch delete request on viewContext
        _ = try? container.viewContext.execute(batchDeleteRequest1)
        
        // repeat above for projects
        let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)

        _ = try? container.viewContext.execute(batchDeleteRequest2)
    }
    
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "items":
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
            
        case "complete":
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
            
        default:
//            fatalError("Unknown award criterion: \(award.criterion)")
            return false 
        }
    }
}
