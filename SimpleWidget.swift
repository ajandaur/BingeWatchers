//
//  SimpleWidget.swift
//  BingeWatchersWidgetExtension
//
//  Created by Anmol  Jandaur on 6/8/22.
//

import SwiftUI
import WidgetKit

struct BingeWatchersWidgetEntryView: View {
    var entry: Provider.Entry
    

    var body: some View {
        VStack {
            Text("Up next..")
                .font(.title)
            
            if let item = entry.items.first {
                Text(item.itemTitle)
            } else {
                Text("Nothing")
            }
        }
    }
}


struct SimpleBingeWatchersWidget: Widget {
    let kind: String = "SimpleBingeWatchersWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BingeWatchersWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Up next…")
        .description("Your #1 top-priority item.")
        .supportedFamilies([.systemSmall])
    }
}


struct BingeWatchersWidget_Previews: PreviewProvider {
    static var previews: some View {
        BingeWatchersWidgetEntryView(entry: SimpleEntry(date: Date(), items: [Item.example]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
