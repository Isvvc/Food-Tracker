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
    @FetchRequest(entity: Food.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var foods: FetchedResults<Food>
    
    @State private var amount: Int = 1
    @State private var foodIndex: Int = 0
    @State private var date: Date = Date()
    @State private var notification: Bool = false
    @State private var alertContents: AlertContents? = nil
    
    let entryController: EntryController
    
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
                        ForEach(0..<6) {
                            Text("\($0) fist\($0 == 1 ? "" : "s")")
                        }
                    }
                    
                    DatePicker(
                        "Entry Date",
                        selection: $date)
                    
                    Toggle("Notification", isOn: $notification)
                        .animation(.default)
                }
                
                Section {
                    Button("Save") {
                        self.entryController.createEntry(
                            food: self.foods[self.foodIndex],
                            amount: Int16(self.amount),
                            timestamp: self.date,
                            notification: self.notification,
                            context: self.moc) { alertContents in
                                if let alertContents = alertContents {
                                    self.alertContents = alertContents
                                    self.notification = false
                                } else {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                        }
                    }
                }
            }
            .navigationBarTitle("New entry")
            .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                Text("Cancel")
            })
            .alert(item: $alertContents) { alertContents in
                Alert(title: Text(alertContents.title), message: Text(alertContents.body))
            }
        }
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return EntryView(entryController: EntryController())
            .environment(\.managedObjectContext, context)
    }
}
