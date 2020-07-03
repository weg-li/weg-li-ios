//
//  CLLocationCoordinate2D+Additions.swift
//  weg-li
//
//  Created by Malte Bünz on 16.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
