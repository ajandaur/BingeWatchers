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
    
    @StateObject var unlockManager: UnlockManager
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    init() {
        let dataController = DataController()
        let unlockManager = UnlockManager(dataController: dataController)
        
        _dataController = StateObject(wrappedValue: dataController)
        _unlockManager = StateObject(wrappedValue: unlockManager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .environmentObject(unlockManager)
            // Automatically save when we detect that we are
            // no longer the foreground app. Use this rather than
            // scene phase so we can port to macOS, where scene
            // phase won't detect our app losing focus.
                .onReceive(NotificationCenter.default.publisher(
                    for: UIApplication.willResignActiveNotification),
                           perform: save
                )
            // Next time you launch the app with at least five projects in your data store, you’ll automatically be prompted to leave a review on the App Store
                .onAppear(perform: dataController.appLaunched)
        }
    }
    
    func save(_ note: Notification) {
        dataController.save()
    }
    
}
