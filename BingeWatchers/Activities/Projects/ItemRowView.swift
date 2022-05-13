//
//  ItemRowView.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 1/11/22.
//

import SwiftUI

struct ItemRowView: View {
    @StateObject var viewModel: ViewModel
    @ObservedObject var item: Item
    
    init(project: Project, item: Item) {
        let viewModel = ViewModel(project: project, item: item)
        _viewModel = StateObject(wrappedValue: viewModel)
        
        self.item = item
    }


    
    var body: some View {
        NavigationLink(destination: EditItemView(item: item)) {
            Label {
                Text(viewModel.title)
            } icon: {
                Image(systemName: viewModel.icon)
                //  if we did get a color string back then turn it into a SwiftUI Color, otherwise use .clear
                    .foregroundColor(viewModel.color.map { Color($0) } ?? .clear)
                        
                    }
            }
        .accessibilityLabel(viewModel.project.label)
    }
}

struct ItemRowView_Previews: PreviewProvider {
    static var previews: some View {
        ItemRowView(project: Project.example, item: Item.example)
    }
}
