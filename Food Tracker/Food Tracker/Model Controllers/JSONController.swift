//
//  JSONController.swift
//  Food Tracker
//
//  Created by Isaac Lyons on 4/6/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData
import SwiftyJSON

class JSONController {
    
    let dateTimeFormatter: ISO8601DateFormatter = {
        let result = ISO8601DateFormatter()
        result.formatOptions = .withInternetDateTime
        
        return result
    }()
    
    let dateFormatter: ISO8601DateFormatter = {
        let result = ISO8601DateFormatter()
        result.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return result
    }()
    
    func export(context: NSManagedObjectContext) throws {
        var json = JSON()
        
        json["foods"] = try export(context: context, jsonForObject: { (food: Food) -> JSON? in
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
            entryJSON["timestamp"].string = dateTimeFormatter.string(from: timestamp)
            entryJSON["food"].string = foodID
            entryJSON["amount"].int16 = entry.amount
            entryJSON["complete"].bool = entry.complete
            
            return entryJSON
        })
        
        json["goals"] = try export(context: context, jsonForObject: { (goal: Goal) -> JSON? in
            guard let startDate = goal.startDate else { return nil }
            
            var goalJSON = JSON()
            goalJSON["timestamp"].string = dateFormatter.string(from: startDate)
            goalJSON["amount"].int16 = goal.amount
            
            return goalJSON
        })
        
        print(json.rawString() ?? "No json returned")
    }
    
    private func export<T: NSManagedObject>(context: NSManagedObjectContext, jsonForObject: (T) throws -> JSON? ) throws -> JSON {
        let fetchRequest = T.fetchRequest() as! NSFetchRequest<T>
        let objects = try context.fetch(fetchRequest)
        
        var json = JSON([])
        for object in objects {
            guard let objectJSON = try jsonForObject(object) else { continue }
            json.arrayObject?.append(objectJSON)
        }
        
        return json
    }
    
}
