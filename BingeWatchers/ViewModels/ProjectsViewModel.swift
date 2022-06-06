//
//  ProjectsViewModel.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 5/12/22.
//

import Foundation
import CoreData
import SwiftUI

// Used an extension on ProjectsView so that ViewModel is nested inside ProjectsView -> this approach doesn't pollute the namespace with view models that apply in only one place.
extension ProjectsView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        
        let dataController: DataController
        
        @Published var sortOrder = Item.SortOrder.optimized
        let showClosedProjects: Bool
        
        private let projectsController: NSFetchedResultsController<Project>
        @Published var projects = [Project]()
        
        // MARK: - IAP Properties
        @Published var showingUnlockView = false
        
        init(dataController: DataController, showClosedProjects: Bool) {
            self.dataController = dataController
            self.showClosedProjects = showClosedProjects
            
            // create an NSFetchRequest that loads our data. We won’t execute this directly, but instead pass it into the fetched results controller so it can keep it updated.
            let request: NSFetchRequest<Project> = Project.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)]
            request.predicate = NSPredicate(format: "closed = %d", showClosedProjects)
            
            // wrap that NSFetchRequest in an NSFetchedResultsController
            // need to pass in a managed object context so the controller knows where to execute the request
            projectsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            //  we inherit from NSObject, so we need to give that class chance to create itself before we change the delegate of our fetched results controller
            super.init()
            // set the view model class as the delegate of the fetched results controller so that it can tell us when the data has changed somehow
            projectsController.delegate = self
            
            // execute the fetch request and assign the projects property
            do {
                try projectsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch projects")
            }
        }
        
        // implement a method in our view model then we’ll get notified when the data changes. We can then pull out the newly updated objects and assign it to our projects array, which will then trigger its @Published property wrapper to announce the update to our UI.
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newProjects = controller.fetchedObjects as? [Project] {
                projects = newProjects
            }
        }
        
        func addProject() {
            if dataController.addProject() == false {
                showingUnlockView.toggle()
            }
        }
        
        func addItem(to project: Project) {
            let item = Item(context: dataController.container.viewContext)
            item.project = project
            item.creationDate = Date()
            dataController.save()
        }
        
        
        
        func delete(_ offsets: IndexSet, from project: Project) {
            let allItems = project.projectItems(using: sortOrder)
            
            for offset in offsets {
                let item = allItems[offset]
                dataController.delete(item)
            }
            
            print(project.projectItems.count)
            
            dataController.save()
        }
        
    }
}
