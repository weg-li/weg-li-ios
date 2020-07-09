//
//  GeoCodeProvider.swift
//  weg-li
//
//  Created by Malte Bünz on 08.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Combine
import CoreLocation

final class GeoCodeProvider {
    func getPlacemarks(for location: CLLocation) -> Future<[Address], Swift.Error> {
        Future<[Address], Swift.Error> { promise in
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, err -> Void in
                if let error = err {
                    return promise(.failure(error))
                }
                guard let marks = placemarks, !marks.isEmpty else {
                    return promise(.failure(Error.noResults))
                }
                return promise(.success(marks.compactMap { $0.postalAddress }))
            }
        }
    }
}

extension GeoCodeProvider {
    enum Error: Swift.Error {
        case noResults
    }
}
