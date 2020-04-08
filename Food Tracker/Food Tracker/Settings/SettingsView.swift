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
                        do {
                            guard let dbURL = try self.jsonController.export(context: self.moc) else { return }
                            
                            let av = UIActivityViewController(activityItems: [dbURL], applicationActivities: nil)
                            
                            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
                        } catch {
                            NSLog("Error exporting database: \(error)")
                        }
                    }, label: {
                        Text("Export Database")
                    })
                    
                    Button(action: {
                        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .import)
                        documentPicker.delegate = self.jsonController
                        self.jsonController.delegate = self
                        
                        UIApplication.shared.windows.first?.rootViewController?.present(documentPicker, animated: true)
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
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem {
            Image(systemName: "gear")
                .imageScale(.large)
            Text("Preferences")
        }
    }
}

extension SettingsView: JSONControllerDelegate {
    func documentPicker(didPickDocumentAt url: URL) {
        do {
            try jsonController.importJSON(fromURL: url, context: self.moc)
        } catch {
            NSLog("Error importing database: \(error)")
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
