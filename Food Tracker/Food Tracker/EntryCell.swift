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
    let entryController: EntryController
    
    let timeFormatter: DateFormatter = {
        let value = DateFormatter()
        value.dateFormat = "h:mm a"
        return value
    }()
    
    var body: some View {
        Button(action: {
            self.entryController.toggleComplete(entry: self.entry, context: self.moc)
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.food?.name ?? "Entry")
                    HStack {
                        Text(self.timeFormatter.string(from: entry.timestamp ?? Date()))
                            .font(.caption)
                        if entry.notification != nil {
                            Image(systemName: "bell.fill")
                                .imageScale(.small)
                        }
                    }
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
