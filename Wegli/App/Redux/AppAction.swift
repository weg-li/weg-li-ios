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

enum AppAction {
    // MARK: Location
    case resolveAddress(Location.LocationOption)
    case setLocation(CLLocationCoordinate2D)
    case setResolvedAddress(CNPostalAddress?)
    
    case setContact(Contact)
    
    // MARK: Image
    case addImage(UIImage)
}
