//
//  GoalController.swift
//  Food Tracker
//
//  Created by Isaac Lyons on 3/30/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import CoreData

class GoalController {
    func createGoal(startDate: Date, amount: Int16, context: NSManagedObjectContext) {
        let goal = Goal(context: context)
        goal.startDate = startDate
        goal.amount = amount
        try? context.save()
    }
    
    func updateGoal(_ goal: Goal, startDate: Date? = nil, amount: Int16? = nil, context: NSManagedObjectContext) {
        if let startDate = startDate {
            goal.startDate = startDate
        }
        
        if let amount = amount {
            goal.amount = amount
        }
        
        try? context.save()
    }
    
    func deleteGoal(_ goal: Goal, context: NSManagedObjectContext) {
        context.delete(goal)
        try? context.save()
    }
}
