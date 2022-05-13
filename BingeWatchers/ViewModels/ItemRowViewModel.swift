//
//  ItemRowViewModel.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 5/13/22.
//

import Foundation
import SwiftUI

extension ItemRowView {
    class ViewModel: ObservableObject {
        let project: Project
        let item: Item
        
        var title: String {
            item.itemTitle
        }
        
        init(project: Project, item: Item) {
            self.project = project
            self.item = item
        }
        
        var icon: String {
            if item.completed {
                return "checkmark.circle"
            } else if item.priority == 3 {
                return "exclamationmark.triangle"
            } else {
                return "checkmark.circle"
            }
        }

        var color: String? {
            if item.completed {
                return project.projectColor
            } else if item.priority == 3 {
                return project.projectColor
            } else {
                return nil
            }
        }
        
        
    }
}
