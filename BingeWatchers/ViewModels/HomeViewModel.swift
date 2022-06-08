//
//  HomeViewModel.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 5/12/22.
//

import Foundation
import CoreData

extension HomeView {
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        private let projectsController: NSFetchedResultsController<Project>
        private let itemsController: NSFetchedResultsController<Item>
        
        @Published var projects = [Project]()
        @Published var items = [Item]()
        @Published var selectedItem: Item?
        
        var dataController: DataController
        
        func selectItem(with identifier: String) {
            selectedItem = dataController.item(with: identifier)
        }
        
        var upNext: ArraySlice<Item> {
            items.prefix(3)
        }
        
        var moreToExplore: ArraySlice<Item> {
            items.dropFirst(3)
        }
        
        func addSampleData() {
            dataController.deleteAll()
            try? dataController.createSampleData()
        }
        
        init(dataController: DataController) {
            self.dataController = dataController
            
            // creating an NSFetchRequest with a predicate and any sort descriptors, then wrapping it inside an NSFetchedResultsController for projects and items
            
            let projectRequest: NSFetchRequest<Project> = Project.fetchRequest()
            projectRequest.predicate = NSPredicate(format: "closed = false")
            projectRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Project.title, ascending: true)]
            
            projectsController = NSFetchedResultsController(
                fetchRequest: projectRequest,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            
            let itemRequest = dataController.fetchRequestForTopItems(count: 10)
            
            itemsController = NSFetchedResultsController(
                    fetchRequest: itemRequest,
                    managedObjectContext: dataController.container.viewContext,
                    sectionNameKeyPath: nil,
                    cacheName: nil
            )
            
            // twice as many delegates, twice as many performFetch() calls, and twice as many reads of fetchedObjects
            super.init()
            
            projectsController.delegate = self
            itemsController.delegate = self
            
            do {
                try projectsController.performFetch()
                try itemsController.performFetch()
                projects = projectsController.fetchedObjects ?? []
                items = itemsController.fetchedObjects ?? []
                
            } catch {
                print("Failed to fetch initial data.")
            }
            
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newItems = controller.fetchedObjects as? [Item] {
                items = newItems
            } else if let newProjects = controller.fetchedObjects as? [Project] {
                projects = newProjects
            }
        }
        
        
        
    }
}
