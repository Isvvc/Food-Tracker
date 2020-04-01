//
//  Defaults.swift
//  Food Tracker
//
//  Created by Isaac Lyons on 4/1/20.
//  Copyright © 2020 Isaac Lyons. All rights reserved.
//

import Foundation

struct Defaults<T: Hashable> {
    enum Key: String {
        case showHistory
        case showWeekOnly
    }
    
    let key: String
    var value: T {
        didSet {
            UserDefaults.standard.set(value, forKey: self.key)
        }
    }
    
    init(key: Key, defaultValue: T) {
        self.key = key.rawValue
        
        if let object = UserDefaults.standard.object(forKey: self.key) as? T {
            value = object
        } else {
            value = defaultValue
        }
    }
}
