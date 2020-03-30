//
//  EntryController.swift
//  Food Tracker
//
//  Created by Isaac Lyons on 3/30/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData
import UserNotifications

class EntryController {
    func createEntry(food: Food, amount: Int16, timestamp: Date, notification: Bool, context: NSManagedObjectContext, completion: @escaping (AlertContents?) -> Void) {
        if notification {
            setNotification(food: food, timestamp: timestamp) { uuid, alertBody in
                if let alertBody = alertBody {
                    completion(AlertContents(title: "Could not set notification", body: alertBody))
                } else {
                    self.createEntry(food: food, amount: amount, timestamp: timestamp, notificationID: uuid, context: context)
                    completion(nil)
                }
            }
        } else {
            createEntry(food: food, amount: amount, timestamp: timestamp, context: context)
            completion(nil)
        }
    }
    
    @discardableResult
    private func createEntry(food: Food, amount: Int16, timestamp: Date, notificationID: UUID? = nil, context: NSManagedObjectContext) -> Entry {
        let newEntry = Entry(context: context)
        newEntry.food = food
        newEntry.amount = amount
        newEntry.timestamp = timestamp
        newEntry.notification = notificationID
        
        try? context.save()
        return newEntry
    }
    
    func toggleComplete(entry: Entry, context: NSManagedObjectContext) {
        entry.complete.toggle()
        
        if entry.complete {
            removeNotifications(for: entry)
        }
        
        try? context.save()
    }
    
    func deleteEntry(entry: Entry, context: NSManagedObjectContext) {
        removeNotifications(for: entry)
        context.delete(entry)
        try? context.save()
    }
    
    private func setNotification(food: Food, timestamp: Date, completion: @escaping (UUID?, String?) -> Void) {
        if timestamp > Date() {
            // Request permission for notifications
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                
                if granted == true && error == nil {
                    // If we have permission
                    let content = UNMutableNotificationContent()
                    content.title = "Time to eat!"
                    content.body = food.name ?? ""
                    content.sound = .default
                    
                    let components = Calendar.current.dateComponents([.day, .hour, .minute], from: timestamp)
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
    }
    
    private func removeNotifications(for entry: Entry) {
        if let uuidString = entry.notification?.uuidString {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuidString])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [uuidString])
        }
        entry.notification = nil
    }
}
