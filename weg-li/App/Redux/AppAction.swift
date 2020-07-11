//
//  AppAction.swift
//  weg-li
//
//  Created by Malte Bünz on 08.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Contacts
import Combine
import Foundation
import MapKit
import UIKit

typealias Address = CNPostalAddress

enum AppAction {
    case setContact(Contact)
    case addImage(UIImage)
    case handleLocationAction(LocationAction)
    case handleDescriptionAction(DescriptionAction)
}

// MARK: Location
extension AppAction {
    enum LocationAction {
        case onLocationAppear
        case requestPermission
        case requestLocation
        case resolveAddress(Location.LocationOption)
        case setUserDefinedLocation(CLLocationCoordinate2D?)
        case setLocation(CLLocationCoordinate2D)
        case setResolvedAddress(Address?)
    }
}

// MARK: Description
extension AppAction {
    enum DescriptionAction {
        case setCar(Report.Car)
        case setCharge(Report.Charge)
        case resolveDistrict(Address)
        case setDistrict(District)
    }
}
