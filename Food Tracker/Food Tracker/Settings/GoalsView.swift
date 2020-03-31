//
//  GoalsView.swift
//  Food Tracker
//
//  Created by Isaac Lyons on 3/30/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import SwiftUI

struct GoalsView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Goal.entity(), sortDescriptors: [NSSortDescriptor(key: "startDate", ascending: true)]) var goals: FetchedResults<Goal>
    
    @State private var showingGoal = false
    @State private var selectedGoal: Goal?
    
    let goalController = GoalController()
    
    let dateFormatter: DateFormatter = {
        let value = DateFormatter()
        value.dateFormat = "EEEE, MMM d"
        return value
    }()
    
    var addGoalButtion: some View {
        Button("Set new goal") {
            self.selectedGoal = nil
            self.showingGoal = true
        }
    }
    
    var body: some View {
        List {
            ForEach(goals, id: \.self) { goal in
                Button(action: {
                    self.selectedGoal = goal
                    self.showingGoal = true
                }) {
                    HStack {
                        Text("Starting \(self.dateFormatter.string(from: goal.startDate ?? Date()))")
                        Spacer()
                        Text("\(goal.amount) fists per day")
                    }
                }
                .foregroundColor(Color(.label))
                
            }
            .onDelete { indexSet in
                let goal = self.goals[indexSet.first!]
                self.goalController.deleteGoal(goal, context: self.moc)
            }
        }
        .navigationBarTitle("Goals")
        .navigationBarItems(trailing: addGoalButtion)
        .sheet(isPresented: $showingGoal) {
            GoalView(goalController: self.goalController, goal: self.selectedGoal)
                .environment(\.managedObjectContext, self.moc)
        }
    }
}

struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return GoalsView()
            .environment(\.managedObjectContext, context)
    }
}
