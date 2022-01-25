//
//  ContentView.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 1/10/22.
//

import SwiftUI

struct ContentView: View {
    
    // Used @SceneStorage vs @AppStorage because when the user actively terminates your app, the data gets deleted. This means they go to the app switcher, and swipe to delete your app.
    @SceneStorage("selectedView") var selectedView: String?
    
    var body: some View {
        TabView(selection: $selectedView) {
            HomeView()
                .tag(HomeView.tag)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            ProjectsView(showClosedProjects: false)
                .tag(ProjectsView.openTag)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Open")
                }

            ProjectsView(showClosedProjects: true)
                .tag(ProjectsView.closedTag)
                .tabItem {
                    Image(systemName: "checkmark")
                    Text("Closed")
                }
            
            AwardsView()
                .tag(AwardsView.tag)
                .tabItem{
                    Image(systemName: "rosette")
                    Text("Awards")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.preview
    
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
    }
}
