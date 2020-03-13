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
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food>
    
    @State private var showingFood = false
        
    var addFoodButton: some View {
        Button(action: { self.showingFood.toggle() }) {
            Image(systemName: "plus")
                .imageScale(.large)
        }
    }
    
    var body: some View {
        NavigationView {
            List(foods, id: \.self) { food in
                Text(food.name ?? "")
            }
            .navigationBarTitle("Foods")
            .navigationBarItems(trailing: addFoodButton)
            .sheet(isPresented: $showingFood) {
                FoodView()
                    .environment(\.managedObjectContext, self.moc)
            }
        }.tabItem {
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
