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
    @FetchRequest(entity: Goal.entity(), sortDescriptors: [NSSortDescriptor(key: "startDate", ascending: false)]) var goals: FetchedResults<Goal>
    
    @State private var showingGoal = false
    @State private var selectedGoal: Goal?
    
    let goalController = GoalController()
    
    var addGoalButtion: some View {
        Button("Set new goal") {
            self.selectedGoal = nil
            self.showingGoal = true
        }
    }
    
    var currentGoal: [Goal] {
        // This returns an array so that it can be rendered using a ForEach to be considered a dynamic cell
        if let firstGoal = goals.first(where: { $0.startDate ?? Date() < Date() }) {
            return [firstGoal]
        }
        
        return []
    }
    
    var futureGoals: [Goal] {
        let currentGoal = self.currentGoal.first
        return goals.filter { $0 != currentGoal && $0.startDate ?? Date() > Date() }
    }
    
    var previousGoals: [Goal] {
        let currentGoal = self.currentGoal.first
        return goals.filter { $0 != currentGoal && $0.startDate ?? Date() < Date() }
    }
    
    var body: some View {
        List {
            // Yes, there is a bit of repitition here with these three sections,
            // but I personally think it'd end up overcomplicating things to abstract it out,
            // and it shouldn't ever need to go beyond these three sections
            if currentGoal.count > 0 {
                Section(header: Text("Current Goal".uppercased())) {
                    // This ForEach is so that there can be an onDelete action on the one cell
                    ForEach(currentGoal, id: \.self) { goal in
                        GoalCell(showingGoal: self.$showingGoal, selectedGoal: self.$selectedGoal, goal: goal)
                    }
                    .onDelete { indexSet in
                        let goal = self.currentGoal[indexSet.first!]
                        self.goalController.deleteGoal(goal, context: self.moc)
                    }
                }
            }
            
            if futureGoals.count > 0 {
                Section(header: Text("Future Goals".uppercased())) {
                    ForEach(futureGoals, id: \.self) { goal in
                        GoalCell(showingGoal: self.$showingGoal, selectedGoal: self.$selectedGoal, goal: goal)
                    }
                    .onDelete { indexSet in
                        let goal = self.futureGoals[indexSet.first!]
                        self.goalController.deleteGoal(goal, context: self.moc)
                    }
                }
            }
            
            if previousGoals.count > 0 {
                Section(header: Text("Previous Goals".uppercased())) {
                    ForEach(previousGoals, id: \.self) { goal in
                        GoalCell(showingGoal: self.$showingGoal, selectedGoal: self.$selectedGoal, goal: goal)
                    }
                    .onDelete { indexSet in
                        let goal = self.previousGoals[indexSet.first!]
                        self.goalController.deleteGoal(goal, context: self.moc)
                    }
                }
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

struct GoalCell: View {
    @Binding var showingGoal: Bool
    @Binding var selectedGoal: Goal?
    
    var goal: Goal
    
    let dateFormatter: DateFormatter = {
        let value = DateFormatter()
        value.dateFormat = "EEEE, MMM d"
        return value
    }()
    
    var body: some View {
        Button(action: {
            self.selectedGoal = self.goal
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
}

struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return GoalsView()
            .environment(\.managedObjectContext, context)
    }
}
