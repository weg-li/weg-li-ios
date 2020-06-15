//
//  AppState.swift
//  Wegli
//
//  Created by Malte Bünz on 08.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Contacts
import Combine
import Foundation
import MapKit
import UIKit

struct Report {
    var images: [UIImage] = []
    var address: CNPostalAddress?
    
    // MARK: Description
    struct Car {
        var color: String?
        var type: String?
        var licensePlateNumber: String?
    }
    var car = Car()
    
    struct Crime {
        var duration: String?
        var type: String?
        var blockedOthers = false
    }
    var crime = Crime()
}

extension Report {
    var isDescriptionValid: Bool {
        ![car.type, car.color, car.licensePlateNumber, crime.type, crime.duration]
            .compactMap { $0 }
            .isEmpty
    }
}

struct AppState {
    var contact: Contact?
    var report: Report
    
    var location: LocationState
}

extension AppState {
    struct LocationState {
        var isAuthorized: Bool = false
        var userDefinedLocation: CLLocationCoordinate2D?
        var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
        var presumedAddress: CNPostalAddress?
    }
}

extension AppState {
    struct ViewRoutingState {
        
    }
}
