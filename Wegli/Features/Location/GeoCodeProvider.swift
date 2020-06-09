//
//  GeoCodeProvider.swift
//  Wegli
//
//  Created by Malte Bünz on 08.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Contacts
import Combine
import CoreLocation

enum GeoCodeError: Error {
    case noResults
}

final class GeoCodeProvider {
    func getPlacemarks(for location: CLLocation) -> Future<[CNPostalAddress], Error> {
        Future<[CNPostalAddress], Error> { promise in
            CLGeocoder().reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "de_DE")) { (placemarks, err) -> Void in
                if let error = err {
                    return promise(.failure(error))
                }
                guard let marks = placemarks, !marks.isEmpty else {
                    return promise(.failure(GeoCodeError.noResults))
                }
                return promise(.success(marks.compactMap { $0.postalAddress }))
            }
        }
    }
}
