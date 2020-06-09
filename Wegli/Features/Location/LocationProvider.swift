// Streckenagent

import Combine
import CoreLocation
import UIKit

final class LocationProvider: NSObject, ObservableObject {
    private var locationFetcher: CLLocationManager
    private var bag = Set<AnyCancellable>()

    private let locationPublisher = PassthroughSubject<CLLocation?, Error>()
    var location: AnyPublisher<CLLocation, Error> {
        locationPublisher
            .compactMap { $0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private let authorizationPublisher = PassthroughSubject<CLAuthorizationStatus, Never>()
    var authorizationStatus: AnyPublisher<Bool, Never> {
        authorizationPublisher
            .map { $0.isAuthorized }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    required init(manager: CLLocationManager = CLLocationManager()) {
        locationFetcher = manager
        super.init()
        locationFetcher.delegate = self
        locationFetcher.desiredAccuracy = kCLLocationAccuracyBest
        
        locationFetcher.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        guard CLLocationManager.authorizationStatus().isAuthorized else {
            locationPublisher.send(completion: .failure(LocationRequestError.unauthorized))
            return
        }
        locationFetcher.requestLocation()
    }
}

// MARK: LocationFetcherDelegate

extension LocationProvider: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationPublisher.send(locations.last)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationPublisher.send(status)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationPublisher.send(completion: .failure(error))
    }
}

extension LocationProvider {
    enum LocationRequestError: Error {
        case unauthorized
    }
}

extension CLAuthorizationStatus {
    var isAuthorized: Bool {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
}
