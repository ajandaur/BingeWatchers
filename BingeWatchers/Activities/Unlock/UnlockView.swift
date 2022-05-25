//
//  UnlockView.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 5/24/22.
//

import SwiftUI
import StoreKit

// If the store is loaded, we’ll read the product out and pass it into a ProductView.

// If the store load failed, we’ll show an error message telling the user to try again later. If you wanted to use the Error value handed to us from UnlockManager you could do so, but it’s not necessary.

struct UnlockView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var unlockManager: UnlockManager
    
    var body: some View {
        VStack {
            switch unlockManager.requestState {
            case .loaded(let product):
                ProductView(product: product)
            case .failed(_):
                Text("Sorry, there was an error loading the store. Please try again later.")
            case .loading:
                ProgressView("Loading...")
            case .purchased:
                Text("Thank you!")
            case .deferred:
                Text("Thank you! Your request is pending approval, but you can carry on using the app in the meantime.")
            }
            
            Button("Dismiss", action: dismiss)
            
        }
        .padding()
        .onReceive(unlockManager.$requestState) { value in
            if case .purchased = value {
                dismiss()
            }
        }
    }
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}
