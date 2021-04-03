// Created for weg-li in 2021.

import Combine
import CoreLocation
@testable import weg_li

struct PlacesServiceMock: PlacesService {
    var subject: PassthroughSubject<[GeoAddress], PlacesServiceImplementation.Error>

    init(getPlacesSubject: PassthroughSubject<[GeoAddress], PlacesServiceImplementation.Error> = .init()) {
        subject = getPlacesSubject
    }

    /// Mock implementation that returns an empty array
    func getPlacemarks(for location: CLLocation) -> AnyPublisher<[GeoAddress], PlacesServiceImplementation.Error> {
        return subject
            .print(">>>")
            .eraseToAnyPublisher()
    }
}
