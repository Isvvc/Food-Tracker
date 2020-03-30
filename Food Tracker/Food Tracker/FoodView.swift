//
//  FoodView.swift
//  Food Tracker
//
//  Created by Isaac Lyons on 3/13/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import SwiftUI

struct FoodView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var name = ""
    
    var food: Food?
    
    init(food: Food? = nil) {
        self.food = food
        _name = .init(initialValue: self.food?.name ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                }
                
                Section {
                    Button("Save") {
                        guard !self.name.isEmpty else { return }
                        
                        if let food = self.food {
                            food.name = self.name
                        } else {
                            let newFood = Food(context: self.moc)
                            newFood.name = self.name
                        }
                        try? self.moc.save()
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationBarTitle("Food item")
            .navigationBarItems(trailing: Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                Text("Cancel")
            })
        }
    }
}

struct FoodView_Previews: PreviewProvider {
    static var previews: some View {
        FoodView()
    }
}
