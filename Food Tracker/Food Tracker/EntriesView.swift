//
//  EntriesView.swift
//  Food Tracker
//
//  Created by Isaac Lyons on 3/13/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import SwiftUI

struct EntriesView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Entry.entity(), sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]) var entries: FetchedResults<Entry>
    
    @State private var showingEntry = false
    
//    let dateFormatter: DateFormatter = {
//        let value = DateFormatter()
//        value.dateStyle = .short
//        value.timeStyle = .short
//        return value
//    }()
    
    var addEntryButton: some View {
        Button(action: { self.showingEntry.toggle() }) {
                        Image(systemName: "plus")
                            .imageScale(.large)
//                            .padding()
                    }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(entries, id: \.self) { entry in
                    HStack {
                        Text(entry.food?.name ?? "Entry")
                        Spacer()
                        Text("\(entry.amount) fists")
                    }
                }
                .onDelete { indexSet in
                    self.moc.delete(self.entries[indexSet.first!])
                }
            }
            .navigationBarTitle("Food Tracker")
            .navigationBarItems(trailing: addEntryButton)
            .sheet(isPresented: $showingEntry) {
                EntryView()
                    .environment(\.managedObjectContext, self.moc)
            }
        }.tabItem {
            Image(systemName: "square.and.pencil")
                .imageScale(.large)
            Text("Entries")
        }
    }
}

struct EntriesView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return EntriesView()
            .environment(\.managedObjectContext, context)
    }
}
