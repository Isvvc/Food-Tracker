//
//  EntryCell.swift
//  Food Tracker
//
//  Created by Isaac Lyons on 3/28/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import SwiftUI

struct EntryCell: View {
    @Environment(\.managedObjectContext) var moc
    
    let entry: Entry
    
    let timeFormatter: DateFormatter = {
        let value = DateFormatter()
        value.dateFormat = "h:mm a"
        return value
    }()
    
    var body: some View {
        Button(action: {
            self.entry.complete.toggle()
            try? self.moc.save()
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.food?.name ?? "Entry")
                    Text(self.timeFormatter.string(from: entry.timestamp ?? Date()))
                        .font(.caption)
                }
                Spacer()
                Text("\(entry.amount) fist\(entry.amount == 1 ? "" : "s")")
                if self.entry.complete {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color(.systemBlue))
                }
            }
        }
        .foregroundColor(Color(.label))
    }
}
