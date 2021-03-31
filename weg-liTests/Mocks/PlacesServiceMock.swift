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
    var subject: PassthroughSubject<[GeoAddress], PlacesServiceImplementation.Error>
    
    init(getPlacesSubject: PassthroughSubject<[GeoAddress], PlacesServiceImplementation.Error> = .init()) {
        self.subject = getPlacesSubject
    }
    
    /// Mock implementation that returns an empty array
    func getPlacemarks(for location: CLLocation) -> AnyPublisher<[GeoAddress], PlacesServiceImplementation.Error> {
        return subject
            .print(">>>")
            .eraseToAnyPublisher()
    }
}
