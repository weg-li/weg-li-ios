//
//  Time.swift
//  weg-li
//
//  Created by Malte Bünz on 16.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Foundation

enum Times: CaseIterable {
    case one
    case three
    case five
    case ten
    case fifteen
    case thirty
    case fourtyfive
    case sixty
    case hundredEighty
    
    var value: Int {
        switch self {
        case .one: return 1
        case .three: return 3
        case .five: return 5
        case .ten: return 10
        case .fifteen: return 15
        case .thirty: return 30
        case .fourtyfive: return 45
        case .sixty: return 60
        case .hundredEighty: return 180
        }
    }
    
    var description: String {
        switch self {
        case .one:
            return "bis zu 3 Minuten"
        case .three, .five, .ten, .fifteen, .thirty, .fourtyfive:
            return "länger als \(value) Minuten"
        case .sixty:
            return "länger als \(value) Stunde"
        case .hundredEighty:
            return "länger als \(value) Stunden"
        }
    }
}
