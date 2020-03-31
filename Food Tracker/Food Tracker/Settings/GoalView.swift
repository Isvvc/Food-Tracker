//
//  GoalView.swift
//  Food Tracker
//
//  Created by Isaac Lyons on 3/30/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import SwiftUI

struct GoalView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var date = Date()
    @State private var amount: Int16 = 18
    
    var goalController: GoalController
    var goal: Goal?
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker(
                        "Start Date",
                        selection: $date,
                        displayedComponents: .date)
                    
                    Stepper(value: $amount, in: 0...64) {
                        Text("\(amount) Fists")
                    }
                }
                
                Section {
                    Button("Save") {
                        self.goalController.createGoal(startDate: self.date, amount: self.amount, context: self.moc)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationBarTitle("Set Goal")
            .navigationBarItems(leading: Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                Text("Cancel")
            })
        }
    }
}

struct GoalView_Previews: PreviewProvider {
    static var previews: some View {
        GoalView(goalController: GoalController())
    }
}
