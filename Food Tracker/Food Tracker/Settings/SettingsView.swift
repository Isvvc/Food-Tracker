//
//  Settings.swift
//  Food Tracker
//
//  Created by Isaac Lyons on 3/30/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) var moc
    
    let links: [(title: String, urlString: String)] = [
        ("Support Website", "https://github.com/Isvvc/Food-Tracker/issues"),
        ("Email Support", "mailto:lyons@tuta.io"),
        ("Privacy Policy", "https://github.com/Isvvc/Food-Tracker/blob/master/Privacy%20Policy.txt"),
        ("Source Code", "https://github.com/Isvvc/Food-Tracker")
    ]
    
    let jsonController = JSONController()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: GoalsView()) {
                        Text("Goals")
                    }
                }
                
                Section(header: Text("Backup".uppercased())) {
                    Button(action: {
                        try? self.jsonController.export(context: self.moc)
                    }, label: {
                        Text("Export Database")
                    })
                    
                    Button(action: {
//                        <#code#>
                    }, label: {
                        Text("Import Database")
                    })
                }
                
                Section(header: Text("App Information".uppercased())) {
                    ForEach(links, id: \.title) { link in
                        Button(action: {
                            guard let url = URL(string: link.urlString) else { return }
                            UIApplication.shared.open(url)
                        }) {
                            Text(link.title)
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Preferences")
        }
        .tabItem {
            Image(systemName: "gear")
                .imageScale(.large)
            Text("Preferences")
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
