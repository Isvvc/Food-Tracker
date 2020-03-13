//
//  EntryView.swift
//  Food Tracker
//
//  Created by Isaac Lyons on 3/13/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import SwiftUI

struct EntryView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food>
    
    @State private var amount: Int = 0
    @State private var foodIndex: Int = 0
    @State private var date: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Food", selection: $foodIndex) {
                        ForEach(0..<foods.count) {
                            Text(self.foods[$0].name ?? "")
                        }
                    }

                    Picker("Amount", selection: $amount) {
                        ForEach(1..<6) {
                            Text("\($0) fist\($0 == 1 ? "" : "s")")
                        }
                    }
                    
                    DatePicker(
                        "Entry Date",
                        selection: $date)
                }
                
                Section {
                    Button("Save") {
                        let newEntry = Entry(context: self.moc)
                        newEntry.food = self.foods[self.foodIndex]
                        newEntry.amount = Int16(self.amount + 1)
                        newEntry.timestamp = self.date
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationBarTitle("New entry")
        }
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return EntryView()
            .environment(\.managedObjectContext, context)
    }
}
