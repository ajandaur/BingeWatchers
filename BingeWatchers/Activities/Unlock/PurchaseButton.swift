//
//  PurchaseButton.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 5/24/22.
//

import SwiftUI

// define a custom button style for our store screen, so the two buttons that involve our upgrade – buying it and restoring a purchase – both stand out from the rest of our app
struct PurchaseButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 200, minHeight: 44)
            .background(Color("Light Blue"))
            .clipShape(Capsule())
            .foregroundColor(.white)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}
