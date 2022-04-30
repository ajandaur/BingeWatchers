//
//  Binding-OnChange.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 1/13/22.
//

import SwiftUI

extension Binding {
    // this method will be stashed away and used later on, hence the @escaping
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        // Binding has two parameters
        // - a function to run to read the binding
        // - a function to run to write the value
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler()
            }
        )
    } // onChange()
}
