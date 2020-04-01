//
//  DaySection.swift
//  Food Tracker
//
//  Created by Isaac Lyons on 3/30/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import SwiftUI

struct DaySection: View {
    
    let day: [Entry]
    let goal: Goal?
    
    init(day: [Entry], goals: [Goal]) {
        self.day = day
        
        guard let date = day.first?.timestamp else {
            self.goal = nil
            return
        }
        
        self.goal = goals.first(where: { goal -> Bool in
            guard let startDate = goal.startDate else { return false }
            return startDate < date
        })
    }
    
    let dateFormatter: DateFormatter = {
        let value = DateFormatter()
        value.dateFormat = "EEEE, MMM d"
        return value
    }()
    
    var planned: Int16 {
        day.map({ $0.amount }).reduce(0, +)
    }
    
    var eaten: Int16 {
        day.filter({ $0.complete }).map({ $0.amount }).reduce(0, +)
    }
    
    var goalAmount: Int16 {
        if let goal = goal {
            return goal.amount
        } else {
            return planned
        }
    }
    
    var progress: CGFloat {
        let denominator = goalAmount
        
        if denominator == 0 {
            return 0
        }
        
        if eaten >= denominator {
            return 1
        }
        
        return CGFloat(eaten) / CGFloat(denominator)
    }
    
    var body: some View {
        Section(header: Text(self.dateFormatter.string(from: day.first?.timestamp ?? Date()))) {
            if goal != nil {
                HStack {
                    Text("Goal:")
                    Spacer()
                    Text("\(self.goal!.amount) fists")
                }
            }
            
            HStack {
                Text("Meals planned:")
                Spacer()
                Text("\(self.planned)")
            }
            
            VStack {
                HStack {
                    Text("Eaten so far:")
                    Spacer()
                    Text("\(self.eaten)/\(self.goalAmount)")
                }
                ZStack(alignment: .leading) {
                    GeometryReader { geometryReader in
                        Capsule()
                            .foregroundColor(Color(UIColor(red: 245/255,
                                                           green: 245/255,
                                                           blue: 245/255,
                                                           alpha: 1.0)))
                        Capsule()
                            .frame(width: geometryReader.size.width * self.progress)
                            .foregroundColor(.green)
                            .animation(.easeInOut)
                    }
                }
            }
        }
    }
}
