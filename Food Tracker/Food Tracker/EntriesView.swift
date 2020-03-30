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
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food>
    
    @State private var showingEntry = false
    @State private var showHistory = false
    @State private var showWeekOnly = true
    @State private var showNoFoodAlert = false
    
    let dateFormatter: DateFormatter = {
        let value = DateFormatter()
        value.dateFormat = "EEEE, MMM d"
        return value
    }()
    
    var addEntryButton: some View {
        Button(action: {
            if self.foods.first == nil {
                self.showNoFoodAlert = true
            } else {
                self.showingEntry = true
            }
        }) {
            Image(systemName: "plus")
                .imageScale(.large)
//                .padding(2)
        }
    }
    
    var filteredEntries: [[Entry]] {
        var results: [[Entry]] = []
        
        guard entries.count > 0 else { return results }
        var index: Int = 0
        results.append([])
        
        for entry in entries {
            if results[index].count == 0 {
                results[index].append(entry)
            } else if let timestamp = entry.timestamp,
                let firstTimestamp = results[index][0].timestamp {
                let entryDay = Calendar.current.startOfDay(for: timestamp)
                let currentDay = Calendar.current.startOfDay(for: firstTimestamp)
                
                if entryDay == currentDay {
                    results[index].append(entry)
                } else {
                    // Check if the date is out of the filtered range
                    if showHistory {
                        if showWeekOnly {
                            guard let weekAgo = Calendar.current.date(byAdding: .day, value: -6, to: Date()) else { break }
                            let weekAgoDay = Calendar.current.startOfDay(for: weekAgo)
                            if entryDay < weekAgoDay {
                                break
                            }
                        }
                        
                        // If not, add it to a new day
                        index += 1
                        results.append([entry])
                    } else {
                        break
                    }
                }
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
                    Text("Show history")
                }
                
                if showHistory {
                    Toggle(isOn: $showWeekOnly) {
                        Text("Show past week only")
                    }
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
                    try? self.moc.save()
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Food Tracker")
            .navigationBarItems(trailing: addEntryButton)
            .sheet(isPresented: $showingEntry) {
                EntryView()
                    .environment(\.managedObjectContext, self.moc)
            }
        }
        .alert(isPresented: $showNoFoodAlert) {
            Alert(title: Text("No foods to choose from"), message: Text("Try adding some foods in the foods tab"))
        }
        .tabItem {
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
