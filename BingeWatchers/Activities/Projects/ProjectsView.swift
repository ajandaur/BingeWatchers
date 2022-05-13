//
//  ProjectsView.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 1/11/22.
//

import SwiftUI

struct ProjectsView: View {
    
    @StateObject var viewModel: ViewModel
    
    static let openTag: String? = "Open"
    static let closedTag: String? = "Closed"
    
    @State private var showingSortOrder = false
    
    
    @State private var sortingKeyPath: PartialKeyPath<Item>?
    @State private var sortDescriptor: NSSortDescriptor?
    
    let sortingKeyPaths = [
        \Item.itemTitle,
         \Item.itemCreationDate
    ]
    
    init(dataController: DataController, showClosedProjects: Bool) {
        let viewModel = ViewModel(dataController: dataController, showClosedProjects: showClosedProjects)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    
    
    var projectsList: some View {
        List {
            ForEach(viewModel.projects) { project in
                Section(header: ProjectHeaderView(project: project)) {
                    ForEach(project.projectItems(using: viewModel.sortOrder)) { item in
                        ItemRowView(project: project, item: item)
                    }
                    .onDelete { offsets in
                        viewModel.delete(offsets, from: project)
                    }
                    
                    if viewModel.showClosedProjects == false {
                        Button {
                            withAnimation {
                                viewModel.addItem(to: project)
                            }
                        } label: {
                            Label("Add New item", systemImage: "plus")
                        }
                    }
                }
            }
        } // LIST
        .listStyle(InsetGroupedListStyle())
    }
    
    var addProjectToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if viewModel.showClosedProjects == false {
                
                Button {
                    withAnimation {
                        viewModel.addProject()
                    }
                } label: {
                    if UIAccessibility.isVoiceOverRunning {
                        Text("Add Project")
                    } else {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    var sortOrderToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                showingSortOrder.toggle()
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.projects.isEmpty {
                    Text("There's nothing here right now")
                        .foregroundColor(.secondary)
                } else {
                    projectsList
                } // ELSE
            } // GROUP
            .navigationTitle(viewModel.showClosedProjects ? "Closed Projects" : "Open Projects")
            .toolbar {
                addProjectToolBarItem
                sortOrderToolBarItem
            }
            
            .actionSheet(isPresented: $showingSortOrder) {
                ActionSheet(title: Text("Sort items"), message: nil, buttons: [
                    .default(Text("Optimized")) { viewModel.sortOrder = .optimized },
                    .default(Text("Creation Date")) { viewModel.sortOrder = .creationDate },
                    .default(Text("Title")) { viewModel.sortOrder = .title }
                ])
            }
            
            // Select something when nothing else is selected
            SelectSomethingView()
        }
    }
    
    
}

struct ProjectsView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    
    static var previews: some View {
        ProjectsView(dataController: DataController.preview, showClosedProjects: false)
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
