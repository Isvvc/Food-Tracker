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
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
            }
            
            Section {
                Button("Save") {
                    let newFood = Food(context: self.moc)
                    newFood.name = self.name
                    try? self.moc.save()
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct FoodView_Previews: PreviewProvider {
    static var previews: some View {
        FoodView()
    }
}
