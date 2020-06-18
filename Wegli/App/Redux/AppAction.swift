//
//  AppAction.swift
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

typealias Address = CNPostalAddress

enum AppAction {
    // MARK: Location
    case handleLocationAction(LocationAction)
    case setContact(Contact)
    // MARK: Image
    case addImage(UIImage)
    case none
    // MARK: Description
    case handleDescriptionAction(DescriptionAction)
    case resolvePublicAffairsOffice(Address)
    case setAffairsOffice(Publicaffairsoffice)
}

extension AppAction {
    enum LocationAction {
        case onLocationAppear
        case requestPermission
        case requestLocation
        case resolveAddress(Location.LocationOption)
        case setUserDefinedLocation(CLLocationCoordinate2D?)
        case setLocation(CLLocationCoordinate2D)
        case setResolvedAddress(CNPostalAddress?)
    }
}

extension AppAction {
    enum DescriptionAction {
        case setCar(Report.Car)
        case setCharge(Report.Charge)
    }
}
