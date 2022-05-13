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
           

        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(dataController: .preview)
    }
}


