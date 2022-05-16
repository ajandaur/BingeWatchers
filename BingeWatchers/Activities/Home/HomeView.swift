//
//  HomeView.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 1/11/22.
//

import SwiftUI
import CoreData
import CoreSpotlight

struct HomeView: View {
    static let tag: String? = "Home"
    
    @StateObject var viewModel: ViewModel
    
    var projectRows: [GridItem] {
        [GridItem(.fixed(100))]
    }
    
    // Construct a fetch request to show the 10 highest-priority, incomplete items from open projects
    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                // Present that item in an EditItemView so the user can see its full details.
                if let item = viewModel.selectedItem {
                    NavigationLink(
                        destination: EditItemView(item: item),
                        tag: item,
                        selection: $viewModel.selectedItem,
                        label: EmptyView.init
                    )
                    // Give the link an ID of the item it is showing, so that if the item changes while the destination view is showing it will be refreshed.
                    .id(item)
                }
                VStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: projectRows) {
                            ForEach(viewModel.projects, content: ProjectSummaryView.init)
                        }
                        .padding([.horizontal, .top])
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    VStack(alignment: .leading) {
                        ItemListView(title: "Up next", items: viewModel.upNext)
                        ItemListView(title: "More to explore", items: viewModel.moreToExplore)
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.systemGroupedBackground.ignoresSafeArea())
            .navigationTitle("Home")
            .toolbar {
                Button("Add Data", action: viewModel.addSampleData)
            }
            // call loadSpotlightItem() when our app is activated by Spotlight
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
           
        } // Nav View]
        
    } // body
    
    // accept any kind of NSUserActivity, then look inside its data to find the unique identifier from Spotlight before passing it to our view model to select
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        // NSUserActivity has a userInfo dictionary, and we need to dig inside that for a specific Core Spotlight key to read out the identifier of our item. If the dictionary exists, if the key exists, and if its value is a string, then we pass that into our view model.
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            viewModel.selectItem(with: uniqueIdentifier)
        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(dataController: .preview)
    }
}


