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
//                .padding(2)
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
    
    func planned(_ entries: [Entry]) -> Int16 {
        entries.map({ $0.amount }).reduce(0, +)
    }
    
    func eaten(_ entries: [Entry]) -> Int16 {
        entries.filter({ $0.complete }).map({ $0.amount }).reduce(0, +)
    }
    
    func progress(_ entries: [Entry]) -> CGFloat {
        CGFloat(eaten(entries)) / CGFloat(planned(entries))
    }
    
    var body: some View {
        NavigationView {
            List {
                Toggle(isOn: $showHistory) {
                    Text("Show past week")
                }
                
                if filteredEntries.count > 0 {
                }
                
                ForEach(filteredEntries, id: \.self) { day in
                    Group {
                        Section(header: Text(self.dateFormatter.string(from: day.first?.timestamp ?? Date()))) {
                            HStack {
                                Text("Fists planned:")
                                Spacer()
                                Text("\(self.planned(day))")
                            }
                            VStack {
                                HStack {
                                    Text("Eaten so far:")
                                    Spacer()
                                    Text("\(self.eaten(day))")
                                }
                                ZStack(alignment: .leading) {
                                    GeometryReader { geometryReader in
                                        Capsule()
                                            .foregroundColor(Color(UIColor(red: 245/255,
                                                                           green: 245/255,
                                                                           blue: 245/255,
                                                                           alpha: 1.0)))
                                        Capsule()
                                            .frame(width: geometryReader.size.width * self.progress(day))
                                            .foregroundColor(.green)
                                            .animation(.easeInOut)
                                    }
                                }
                            }
                        }
                        
                        Section {
                            ForEach(day, id: \.self) { entry in
                                EntryCell(entry: entry)
                            }
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
