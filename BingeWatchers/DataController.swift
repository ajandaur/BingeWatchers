//
//  DataController.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 1/10/22.
//

import CoreData
import SwiftUI
import CoreSpotlight
import UserNotifications
import StoreKit

///  An environment singleton responsible for managing our Core Data stack, including handling saving,
/// counting fetch requests, tracking awards, and dealing with sample data.
class DataController: ObservableObject {
    
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    /// The lone CloudKit container used to store all our data.
    let container: NSPersistentCloudKitContainer
    
    // The UserDefaults suite where we're saving user data.
    // Using UserDefaults as a singleton like "UserDefaults.standard" causes problems if you ever want to add tests for this new code because it creates a hidden dependency
    let defaults: UserDefaults
    
    // Loads and saves whether our premium unlock has been purchased.
    var fullVersionUnlocked: Bool {
        get {
            defaults.bool(forKey: "fullVersionUnlocked")
        }
        
        set {
            defaults.set(newValue, forKey: "fullVersionUnlocked")
        }
    }
    
    
    /// Initializes a data controller, either in memory (for temporary use such as testing and previewing),
    /// or on permanent storage (for use in regular app runs.)
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
        self.defaults = defaults
        
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

        // For testing and previewing purposes, we create a
        // temporary, in-memory database by writing to /dev/null
        // so our data is destroyed after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
            
            // respond to that configuration by deleting any existing data
            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self.deleteAll()
                UIView.setAnimationsEnabled(false)
            }
            #endif
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
    
    
    /// Creates example projects and items to make manual testing easier.
    /// - Throws: An NSError sent from calling save() on the NSManagedObjectContext.
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
    
    // MARK: - Requesting a review
    // finding the first active scene (that’s the one currently receiving user input), then asking for a review prompt to appear there
    func appLaunched() {
        guard count(for: Project.fetchRequest()) >= 5 else { return }
        
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }
        
        if let windowScene = scene as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    /// Saves our Core Data context iff there are changes. This silently ignores
    /// any errors caused by saving, but this should be fine because all our attributes are optional.
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    
    // delete a project
    func delete(_ object: Project) {
        let id = object.objectID.uriRepresentation().absoluteString
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [id])
        
        container.viewContext.delete(object)
    }
    // delete an item
    func delete(_ object: Item) {
        let id = object.objectID.uriRepresentation().absoluteString
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])
        
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
            // returns true if they added a certain number of items
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
            
        case "complete":
            // returns true if they completed a certain number of items
            let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
            
        default:
            // an unknown award criterion; this should never be allowed
//            fatalError("Unknown award criterion: \(award.criterion)")
            return false 
        }
    }
    
    ///  update() method that accepts a particular item. Internally this will write that item’s information to Spotlight, then also call save() on the data controller so it updates Core Data as well.
    func update(_ item: Item) {
        /// 1. Creating a unique identifier for the item you want to save. If you’re updating an existing item you should use the same identifier.
        let itemID = item.objectID.uriRepresentation().absoluteString
        let projectID = item.project?.objectID.uriRepresentation().absoluteString
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        /// 2. Decide what attributes you want to store in Spotlight. There are hundreds of these to choose from, but you’ll probably want title and description at the very least.
        attributeSet.title = item.title
        attributeSet.contentDescription = item.detail
        
        /// 3. Wrap up the identifier and attributes in a Spotlight record, also passing in a domain identifier – a way to group certain pieces of data together.
        let searchableItem = CSSearchableItem(
            uniqueIdentifier: itemID,
            domainIdentifier: projectID,
            attributeSet: attributeSet
        )
        
        /// 4. Send that off to Spotlight for indexing.
        CSSearchableIndex.default().indexSearchableItems([searchableItem])
        
        save()
    }
    
    // convert a string back to a URL, then get the object ID for that, and finally pull out the object for that ID.
    func item(with uniqueIdentifier: String) -> Item? {
        // 1. Figure out which object was selected. Core Spotlight will pass us the unique identifier we saved, so we need to convert that into an Item.
        guard let url = URL(string: uniqueIdentifier) else { return nil }
        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else { return nil }
        return try? container.viewContext.existingObject(with: id) as? Item 
    }
    
    // MARK: - Local Notifications
    
    //  method that will be called from EditProjectView to add a reminder for a project
    func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotifications { success in
                    if success {
                        self.placeReminders(for: project, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            case . authorized:
                self.placeReminders(for: project, completion: completion)
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    // method that will be called from EditProjectView to remove a reminder for a project
    func removeReminders(for project: Project) {
        //  every managed object has an objectID property that can be converted into a URL designed specifically for archiving
        let center = UNUserNotificationCenter.current()
        let id = project.objectID.uriRepresentation().absoluteString
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    // This method is going to request notification authorization from iOS, asking to be able to show an alert and play a sound, then call its completion handler with whatever the system replies back with – in this case, whether the authorization was granted or not.
    private func requestNotifications(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            completion(granted)
        }
    }
    
    // second private method that does the work of placing a single notification for a project
    private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        //  UNMutableNotificationContent, where we describe how the notification should look to the system – what title it has, whether a picture is attached, whether it should be grouped with other similar notifications, and more
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = project.projectTitle
        
        if let projectDetail = project.detail {
            content.subtitle = projectDetail
        }
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: project.reminderTime ?? Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // wrap up the content and trigger in a single notification, giving it a unique ID
        let id = project.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
