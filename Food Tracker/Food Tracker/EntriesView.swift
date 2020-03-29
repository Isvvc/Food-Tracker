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
    @FetchRequest(
        entity: Entry.entity(),
        sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]
    ) var entries: FetchedResults<Entry>
    
    @State private var showingEntry = false
    @State private var showHistory = false
    
    let dateFormatter: DateFormatter = {
        let value = DateFormatter()
        value.dateFormat = "EEEE, MMM d"
        return value
    }()
    
    var addEntryButton: some View {
        Button(action: { self.showingEntry.toggle() }) {
                        Image(systemName: "plus")
                            .imageScale(.large)
//                            .padding(2)
                    }
    }
    
    var datesToShow: [Date] {
        if showHistory {
            var dates = [Date()]
            for i in 1..<7 {
                guard let date = Calendar.current.date(byAdding: .day, value: i * -1, to: Date()) else { continue }
                dates.append(date)
            }
            
            return dates
        }
        
        return [Date()]
    }
    
    var filteredEntries: [[Entry]] {
        var results: [[Entry]] = []
        var remainingEntries = entries.compactMap { $0 }
        
        for i in 0..<(showHistory ? 7 : 1) {
            guard let date = Calendar.current.date(byAdding: .day, value: i * -1, to: Date()) else { continue }
            
            let filteredEntries = remainingEntries.filter { entry -> Bool in
                if let timestamp = entry.timestamp {
                    return timestamp > Calendar.current.startOfDay(for: date)
                }
                
                return false
            }
            
            if filteredEntries.count > 0 {
                results.append(filteredEntries)
                remainingEntries.removeAll(where: { filteredEntries.contains($0) })
            }
        }
        
        return results
    }
    
    var body: some View {
        NavigationView {
            List {
                Toggle(isOn: $showHistory) {
                    Text("Show history")
                }
                
                ForEach(filteredEntries, id: \.self) { day in
                    Section(header: Text(self.dateFormatter.string(from: day.first?.timestamp ?? Date()))) {
                        ForEach(day, id: \.self) { entry in
                            EntryCell(entry: entry)
                        }
                    }
                }
                .onDelete { indexSet in
                    self.moc.delete(self.entries[indexSet.first!])
                }
            }
            .listStyle(GroupedListStyle())
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
