//
//  FoodsView.swift
//  Food Tracker
//
//  Created by Isaac Lyons on 3/13/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import SwiftUI

struct FoodsView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Food.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)]) var foods: FetchedResults<Food>
    
    @State private var showingFood = false
    @State private var selectedFood: Food?
        
    var addFoodButton: some View {
        Button(action: {
            self.selectedFood = nil
            self.showingFood.toggle()
        }) {
            Image(systemName: "plus")
                .imageScale(.large)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(foods, id: \.self) { food in
                    Button(action: {
                        self.selectedFood = food
                        self.showingFood.toggle()
                    }) {
                        Text(food.name ?? "")
                    }
                }
                .onDelete { indexSet in
                    let food = self.foods[indexSet.first!]
                    
                    self.moc.delete(food)
                    try? self.moc.save()
                }
            }
            .navigationBarTitle("Foods")
            .navigationBarItems(trailing: addFoodButton)
            .sheet(isPresented: $showingFood) {
                FoodView(food: self.selectedFood)
                    .environment(\.managedObjectContext, self.moc)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem {
            Image(systemName: "list.bullet")
                .imageScale(.large)
            Text("Foods")
        }
    }
}

struct FoodsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return FoodsView()
            .environment(\.managedObjectContext, context)
    }
}
