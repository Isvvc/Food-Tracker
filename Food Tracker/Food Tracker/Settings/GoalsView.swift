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
    
    var body: some View {
        List {
            if goals.count > 0 {
                Section(header: Text("Current Goal".uppercased())) {
                    // This ForEach is so that there can be an onDelete action on the one cell
                    ForEach([goals.first!], id: \.self) { goal in
                        GoalCell(showingGoal: self.$showingGoal, selectedGoal: self.$selectedGoal, goal: goal)
                    }
                    .onDelete { indexSet in
                        guard let goal = self.goals.first else { return }
                        self.goalController.deleteGoal(goal, context: self.moc)
                    }
                }
            }
            
            if goals.count > 1 {
                Section(header: Text("Previous Goals".uppercased())) {
                    ForEach(goals.dropFirst(), id: \.self) { goal in
                        GoalCell(showingGoal: self.$showingGoal, selectedGoal: self.$selectedGoal, goal: goal)
                    }
                    .onDelete { indexSet in
                        let goal = self.goals[indexSet.first! + 1]
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
