//
//  Project-CoreDataHelpers.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 1/11/22.
//

import Foundation

extension Project {
    var projectTitle: String {
        title ?? "New Project"
    }
    
    var projectDetail: String {
        detail ?? ""
    }
    
    var projectColor: String {
        color ?? "Light Blue"
    }
    
    var projectItems: [Item] {
        let itemArray = items?.allObjects as? [Item] ?? []
        
        return itemArray.sorted { first, second in
            if first.completed == false {
                if second.completed == true {
                    return true
                }
            } else if first.completed == true {
                if second.completed == false {
                    return false
                }
            }
            
            if first.priority > second.priority {
                return true
            } else if first.priority < second.priority {
                return false
            }
            
            // both completed or not completed and both have same priority..
            return first.itemCreationDate < second.itemCreationDate
        }
    }
    
    var completionAmount: Double {
        let originaltems = items?.allObjects as? [Item] ?? []
        guard originaltems.isEmpty == false else { return 0 }
        
        // look for any items that have completed set to true
        let completedItems = originaltems.filter(\.completed)
        return Double(completedItems.count) / Double(originaltems.count)
    }
    
    static var example: Project {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let project = Project(context: viewContext)
        project.title = "Example Project"
        project.detail = "This is an example project"
        project.closed = true
        project.creationDate = Date()
        
        return project
    }
    
}
