//
//  PlacesServiceMock.swift
//  weg-liTests
//
//  Created by Malte on 30.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

@testable import weg_li
import Combine
import CoreLocation

struct PlacesServiceMock: PlacesService {
    /// Mock implementation that returns an empty array
    func getPlacemarks(for location: CLLocation) -> Future<[GeoAddress], PlacesServiceImplementation.Error> {
        return Future { promise in
            promise(.success([]))
        }
    }
}
