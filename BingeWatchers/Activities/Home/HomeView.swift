//
//  HomeView.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 1/11/22.
//

import SwiftUI
import CoreData

struct HomeView: View {
    static let tag: String? = "Home"
    
    @EnvironmentObject var dataController: DataController
    
    @FetchRequest(
        entity: Project.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)],
        predicate: NSPredicate(format: "closed = false")
    ) var projects: FetchedResults<Project>
    
    let items: FetchRequest<Item>
    
    var projectRows: [GridItem] {
        [GridItem(.fixed(100))]
    }
    
    // Construct a fetch request to show the 10 highest-priority, incomplete items from open projects
    init() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        // when a project is marked as completed its items should no longer appear in the Home view
        let completedPredicate = NSPredicate(format: "completed = false")
        //  rather than placing all our logic into a single string, we can break it up into components then group them back to gather with logical operators such as .and
        let openPredicate = NSPredicate(format: "project.closed = false")
        // make two predicates: this item must not be completed, and its parent project must not be closed
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [completedPredicate, openPredicate])
        
        request.predicate = compoundPredicate
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Item.priority, ascending: false)
        ]
        
        request.fetchLimit = 10
        items = FetchRequest(fetchRequest: request)
    }
    
 
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(projects, content: ProjectSummaryView.init)
                        }
                        .padding([.horizontal, .top])
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: items.wrappedValue.prefix(3))
                        ItemListView(title: "More to explore", items: items.wrappedValue.dropFirst(3))
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Home")
            .toolbar {
                Button("Add Data") {
                    dataController.deleteAll()
                    try? dataController.createSampleData()
                }
            }
           

        }
    }
    
}


