// Created for weg-li in 2021.

import Combine
import CoreLocation

protocol PlacesService {
    func getPlacemarks(for location: CLLocation) -> AnyPublisher<[GeoAddress], PlacesServiceImplementation.Error>
}

final class PlacesServiceImplementation: PlacesService {
    func getPlacemarks(for location: CLLocation) -> AnyPublisher<[GeoAddress], PlacesServiceImplementation.Error> {
        Future<[GeoAddress], PlacesServiceImplementation.Error> { promise in
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error -> Void in
                if error != nil {
                    return promise(.failure(Error()))
                }
                guard let marks = placemarks, !marks.isEmpty else {
                    return promise(.failure(Error()))
                }
                return promise(
                    .success(
                        marks
                            .compactMap { $0.postalAddress }
                            .map { GeoAddress(address: $0) }
                    )
                )
            }
        }
        .eraseToAnyPublisher()
    }
}

struct GeoAddress: Hashable, Codable {
    var street: String
    var city: String
    var postalCode: String

    var isValid: Bool {
        return [street, city, postalCode]
            .allSatisfy { !$0.isEmpty }
    }
}

extension PlacesServiceImplementation {
    struct Error: Swift.Error, Equatable {
        init() {}
    }
}
