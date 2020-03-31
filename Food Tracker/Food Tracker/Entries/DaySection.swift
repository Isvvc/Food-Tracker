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
    
    let dateFormatter: DateFormatter = {
        let value = DateFormatter()
        value.dateFormat = "EEEE, MMM d"
        return value
    }()
    
    func planned(_ entries: [Entry]) -> Int16 {
        entries.map({ $0.amount }).reduce(0, +)
    }
    
    func eaten(_ entries: [Entry]) -> Int16 {
        entries.filter({ $0.complete }).map({ $0.amount }).reduce(0, +)
    }
    
    func progress(_ entries: [Entry]) -> CGFloat {
        if planned(entries) == 0 {
            return 0
        }
        
        return CGFloat(eaten(entries)) / CGFloat(planned(entries))
    }
    
    var body: some View {
        Section(header: Text(self.dateFormatter.string(from: day.first?.timestamp ?? Date()))) {
            HStack {
                Text("Fists planned:")
                Spacer()
                Text("\(self.planned(day))")
            }
            VStack {
                HStack {
                    Text("Eaten so far:")
                    Spacer()
                    Text("\(self.eaten(day))")
                }
                ZStack(alignment: .leading) {
                    GeometryReader { geometryReader in
                        Capsule()
                            .foregroundColor(Color(UIColor(red: 245/255,
                                                           green: 245/255,
                                                           blue: 245/255,
                                                           alpha: 1.0)))
                        Capsule()
                            .frame(width: geometryReader.size.width * self.progress(self.day))
                            .foregroundColor(.green)
                            .animation(.easeInOut)
                    }
                }
            }
        }
    }
}
