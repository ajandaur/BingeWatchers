//
//  ItemListView.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 2/4/22.
//

import SwiftUI

struct ItemListView: View {
    
    let title: LocalizedStringKey
    let items: FetchedResults<Item>.SubSequence
    
    var body: some View {
        if items.isEmpty {
            // send back an empty view
            EmptyView()
        } else {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top)
            
            ForEach(items) { item in
                NavigationLink(destination: EditItemView(item: item)) {
                    HStack(spacing: 20) {
                        Circle()
                            .stroke(Color(item.project?.projectColor ?? "Light Blue"), lineWidth: 3)
                            .frame(width: 44, height: 44)
                        
                        VStack(alignment: .leading) {
                            Text(item.itemTitle)
                                .font(.title2)
                                .foregroundColor(.primary)
                                .frame(width: .infinity, alignment: .leading)
                            
                            if item.itemDetail.isEmpty == false {
                                Text(item.itemDetail)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.secondarySystemGroupedBackground)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                  
                    
                }
            }
        }
    }
}
