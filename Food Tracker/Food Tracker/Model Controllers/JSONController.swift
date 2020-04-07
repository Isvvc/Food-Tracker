//
//  JSONController.swift
//  Food Tracker
//
//  Created by Isaac Lyons on 4/6/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData
import SwiftyJSON
import SwiftUI

protocol JSONControllerDelegate {
    func documentPicker(didPickDocumentAt url: URL)
}

class JSONController: NSObject, ObservableObject {
    
    var delegate: JSONControllerDelegate?
    
    let timestampFormatter: ISO8601DateFormatter = {
        let result = ISO8601DateFormatter()
        result.formatOptions = .withInternetDateTime
        
        return result
    }()
    
    let dateFormatter: ISO8601DateFormatter = {
        let result = ISO8601DateFormatter()
        result.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return result
    }()
    
    private var dbFileURL: URL? {
        let fileManager = FileManager.default
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        return documents.appendingPathComponent("food-tracker-db_\(dateFormatter.string(from: Date())).json")
    }
    
    func export(context: NSManagedObjectContext) throws -> URL? {
        var json = JSON()
        
        json["foods"] = try export(context: context, jsonForObject: { (food: Food) -> JSON? in
            if food.id == nil {
                food.id = UUID()
            }
            
            guard let id = food.id?.uuidString,
                let name = food.name else { return nil }
            
            var foodJSON = JSON()
            foodJSON["id"].string = id
            foodJSON["name"].string = name
            
            return foodJSON
        })
        
        json["entries"] = try export(context: context, jsonForObject: { (entry: Entry) -> JSON? in
            guard let timestamp = entry.timestamp,
                let foodID = entry.food?.id?.uuidString else { return nil }

            var entryJSON = JSON()
            entryJSON["timestamp"].string = timestampFormatter.string(from: timestamp)
            entryJSON["food"].string = foodID
            entryJSON["amount"].int16 = entry.amount
            entryJSON["complete"].bool = entry.complete
            
            return entryJSON
        })
        
        json["goals"] = try export(context: context, jsonForObject: { (goal: Goal) -> JSON? in
            guard let startDate = goal.startDate else { return nil }
            
            var goalJSON = JSON()
            goalJSON["startDate"].string = dateFormatter.string(from: startDate)
            goalJSON["amount"].int16 = goal.amount
            
            return goalJSON
        })
        
        guard let str = json.rawString(),
            let url = dbFileURL else { return nil }

        try str.write(to: url, atomically: true, encoding: .utf8)
        
        return url
    }
    
    private func export<T: NSManagedObject>(context: NSManagedObjectContext, jsonForObject: (T) -> JSON? ) throws -> JSON {
        let fetchRequest = T.fetchRequest() as! NSFetchRequest<T>
        let objects = try context.fetch(fetchRequest)
        
        var json = JSON([])
        for object in objects {
            guard let objectJSON = jsonForObject(object) else { continue }
            json.arrayObject?.append(objectJSON)
        }
        
        return json
    }
    
    func importJSON(fromURL url: URL, context: NSManagedObjectContext) throws {
        let data = try Data(contentsOf: url)
        let json = try JSON(data: data)
        
        // JSONImporter exists as a separate class as trying to use the exact same generic function
        // as a JSONController class would not generalize properly and would expect updateObject's
        // first argument to be a NSManagedObject, not a NSManagedObject subclass
        let foodImporter = JSONImporter<Food>()
        let allFoods = try foodImporter.importObjects(
            json: json["foods"],
            context: context,
            objectsMatch: { (food: Food, json: JSON) -> Bool in
                food.id?.uuidString == json["id"].string
        },
            updateObject: { food, json in
                let newName = json["name"].string
                if food.name != newName {
                    // Prevent updating objects if there is nothing to change
                    food.name = newName
                }
        },
            createObject: { json in
                let newFood = Food(context: context)
                newFood.id = UUID()
                newFood.name = json["name"].string
                
                return newFood
        })
        
        let entryImporter = JSONImporter<Entry>()
        try entryImporter.importObjects(
            json: json["entries"],
            context: context,
            objectsMatch: { (entry: Entry, json: JSON) -> Bool in
                guard let timestamp = entry.timestamp else { return false }
                return timestampFormatter.string(from: timestamp) == json["timestamp"].string
        },
            updateObject: { entry, json in
                if let timestampString = json["timestamp"].string,
                    let timestamp = timestampFormatter.date(from: timestampString),
                    timestamp != entry.timestamp {
                    entry.timestamp = timestamp
                }
                
                if let foodString = json["food"].string,
                    let foodID = UUID(uuidString: foodString),
                    foodID != entry.food?.id,
                    let food = allFoods.first(where: { $0.id == foodID }) {
                    entry.food = food
                }
                
                if let amount = json["amount"].int16,
                    entry.amount != amount {
                    entry.amount = amount
                }
                
                if let complete = json["complete"].bool,
                    entry.complete != complete {
                    entry.complete = complete
                }
        },
            createObject: { json in
                guard let timestampString = json["timestamp"].string,
                    let timestamp = timestampFormatter.date(from: timestampString),
                    let foodString = json["food"].string,
                    let foodID = UUID(uuidString: foodString),
                    let food = allFoods.first(where: { $0.id == foodID }),
                    let amount = json["amount"].int16,
                    let complete = json["complete"].bool else { return nil }
                
                let newEntry = Entry(context: context)
                newEntry.food = food
                newEntry.amount = amount
                newEntry.timestamp = timestamp
                newEntry.complete = complete
                
                return newEntry
        })
        
        let goalsImporter = JSONImporter<Goal>()
        try goalsImporter.importObjects(
            json: json["goals"],
            context: context,
            objectsMatch: { (goal: Goal, json: JSON) -> Bool in
                guard let startDate = goal.startDate else { return false }
                return json["startDate"].string == dateFormatter.string(from: startDate)
        },
            updateObject: { goal, json in
                if let amount = json["amount"].int16,
                    goal.amount != amount {
                    goal.amount = amount
                }
        },
            createObject: { json -> Goal? in
                guard let startDateString = json["startDate"].string,
                    let startDate = dateFormatter.date(from: startDateString),
                    let amount = json["amount"].int16 else { return nil }
                
                let newGoal = Goal(context: context)
                newGoal.startDate = startDate
                newGoal.amount = amount
                
                return newGoal
        })
        
        try context.save()
    }
    
}

extension JSONController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        delegate?.documentPicker(didPickDocumentAt: url)
    }
}

class JSONImporter<T: NSManagedObject> {
    @discardableResult func importObjects(
        json: JSON,
        context: NSManagedObjectContext,
        objectsMatch: (T, JSON) -> Bool,
        updateObject: (T, JSON) -> Void,
        createObject: (JSON) -> T?) throws -> [T] {
        
        let fetchRequest = T.fetchRequest() as! NSFetchRequest<T>
        var existingObjects = try context.fetch(fetchRequest)
        
        for jsonObject in json.arrayValue {
            if let existingObject = existingObjects.first(where: { objectsMatch($0, jsonObject) }) {
                updateObject(existingObject, jsonObject)
            } else {
                if let newObject = createObject(jsonObject) {
                    existingObjects.append(newObject)
                }
            }
        }
        
        return existingObjects
    }
}
