//
//  Report.swift
//  weg-li
//
//  Created by Malte Bünz on 16.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Foundation
import UIKit

struct Report {
    var images: [UIImage] = []
    var address: Address?
    var suggestedublicAffairsOffice: Publicaffairsoffice?
    
    var date: Date = Date()
    var car = Car()
    var charge = Charge()
}

extension Report {
    // MARK: Description
    struct Car {
        var color: String?
        var type: String?
        var licensePlateNumber: String?
    }
    
    struct Charge {
        var selectedDuration = 0
        var selectedType = 0
        var blockedOthers = false
        
        var humandReadableCharge: String { Charge.charges[selectedType] }
        var time: String { Times.allCases[selectedDuration].description }
    }
}

extension Report {
    var isDescriptionValid: Bool {
        guard let type = car.type, let color = car.color, let plate = car.licensePlateNumber else {
            return false
        }
        let isValid = ![type, color, plate]
            .map { $0.isEmpty }
            .contains(true)
        return isValid
    }
}

extension Report.Charge {
    static let charges = Bundle.main.decode([String].self, from: "charges.json")
    static let times = Times.allCases
}
