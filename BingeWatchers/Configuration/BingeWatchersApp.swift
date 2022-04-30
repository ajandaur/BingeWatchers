//
//  BingeWatchersApp.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 1/10/22.
//

import SwiftUI

@main
struct BingeWatchersApp: App {
    // use @StatObject when  you need to create a reference type inside one of your views and
    // make sure it stays alive for use in that view and others you share it with
    @StateObject var dataController: DataController
    
    init() {
        let dataController = DataController()
        _dataController = StateObject(wrappedValue: dataController)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
            // Automatically save when we detect that we are
            // no longer the foreground app. Use this rather than
            // scene phase so we can port to macOS, where scene
            // phase won't detect our app losing focus.
                .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.willResignActiveNotification),
                           perform: save
                )
        }
    }
    
    func save(_ note: Notification) {
        dataController.save()
    }
    
}
