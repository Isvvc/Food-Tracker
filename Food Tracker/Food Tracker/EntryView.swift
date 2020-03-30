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
    
    @State private var amount: Int = 0
    @State private var foodIndex: Int = 0
    @State private var date: Date = Date()
    @State private var notification: Bool = false
    @State private var alertContents: AlertContents? = nil
    
    private func setNotification(completion: @escaping (UUID?, String?) -> Void) {
        if self.notification {
            if self.date > Date() {
                // Request permission for notifications
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                    
                    if granted == true && error == nil {
                        // If we have permission
                        let content = UNMutableNotificationContent()
                        content.title = "Time to eat!"
                        content.body = self.foods[self.foodIndex].name ?? ""
                        content.sound = .default
                        
                        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: self.date)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                        
                        let uuid = UUID()
                        let request = UNNotificationRequest(identifier: uuid.uuidString, content: content, trigger: trigger)
                        
                        let notificationCenter = UNUserNotificationCenter.current()
                        notificationCenter.add(request) { error in
                            if let error = error {
                                NSLog("\(error)")
                            }
                        }
                        
                        completion(uuid, nil)
                    } else {
                        completion(nil, "Please enable notifications in the settings app.")
                    }
                }
            } else {
                completion(nil, "Can't set a notification in the past.")
            }
        } else {
            completion(nil, nil)
        }
    }
    
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
                    
                    Toggle("Notification", isOn: $notification)
                        .animation(.default)
                }
                
                Section {
                    Button("Save") {
                        self.setNotification { uuid, alertBody in
                            if let alertBody = alertBody {
                                self.alertContents = AlertContents(title: "Could not set notification", body: alertBody)
                                self.notification = false
                            } else {
                                let newEntry = Entry(context: self.moc)
                                newEntry.food = self.foods[self.foodIndex]
                                newEntry.amount = Int16(self.amount + 1)
                                newEntry.timestamp = self.date
                                newEntry.notification = uuid
                                
                                try? self.moc.save()
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("New entry")
            .alert(item: $alertContents) { alertContents in
                Alert(title: Text(alertContents.title), message: Text(alertContents.body))
            }
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
