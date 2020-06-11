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
}

struct LocationState {
    var isAuthorized: Bool = false
    var userDefinedLocation: CLLocationCoordinate2D?
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var presumedAddress: CNPostalAddress?
}

struct AppState {
    var contact: Contact?
    var report: Report
    
    var location: LocationState
}
