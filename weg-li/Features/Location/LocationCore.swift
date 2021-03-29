//
//  LocationCore.swift
//  weg-li
//
//  Created by Malte on 25.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

import ComposableArchitecture
import ComposableCoreLocation
import Foundation
import MapKit
import SwiftUI

enum UserLocationError: Error {
    case accessDenied
    case locationNotFound
}

// MARK: - UserLocationState
struct UserLocationState: Equatable {
    var alert: AlertState<ReportAction>?
    var isRequestingCurrentLocation = false
    var region: CoordinateRegion?
    
    init(
        alert: AlertState<ReportAction>? = nil,
        isRequestingCurrentLocation: Bool = false,
        region: CoordinateRegion? = nil
    ) {
        self.alert = alert
        self.isRequestingCurrentLocation = isRequestingCurrentLocation
        self.region = region
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.isRequestingCurrentLocation == rhs.isRequestingCurrentLocation
            && lhs.region?.center.latitude == rhs.region?.center.latitude
            && lhs.region?.center.longitude == rhs.region?.center.longitude
    }
}

struct UserLocationEnvironment {
    let locationManager: LocationManager
}

// TCA uses Hashable structs for identifying effects
private struct LocationManagerId: Hashable {}
private struct CancelSearchId: Hashable {}

let locationManagerReducer = Reducer<UserLocationState, LocationManager.Action, UserLocationEnvironment> {
    state, action, environment in
    switch action {
    case .didChangeAuthorization(.authorizedAlways),
         .didChangeAuthorization(.authorizedWhenInUse):
        if state.isRequestingCurrentLocation {
            return environment.locationManager
                .requestLocation(id: LocationManagerId())
                .fireAndForget()
        }
        return .none
        
    case .didChangeAuthorization(.denied):
        if state.isRequestingCurrentLocation {
            state.alert = .init(
                title: TextState("Location makes this app better. Please consider giving us access.") // l18n
            )
            state.isRequestingCurrentLocation = false
        }
        return .none
        
    case let .didUpdateLocations(locations):
        state.isRequestingCurrentLocation = false
        guard let location = locations.first else { return .none }
        state.region = CoordinateRegion(center: location.coordinate)
        return .none
    case let .didFailWithError(error):
        print(error.localizedDescription)
        return .none
        
    default:
        return .none
    }
}

// MARK: - Location Core

struct LocationViewState: Equatable, Codable {
    var locationOption: LocationOption = .fromPhotos(nil)
    var isMapExpanded = false
    var isResolvingAddress = false
    var resolvedAddress: GeoAddress = .init(address: .init())
    var storedPhotos: [StorableImage]
    var userLocationState = UserLocationState()
    
    private enum CodingKeys: String, CodingKey {
        case locationOption
        case isMapExpanded
        case isResolvingAddress
        case resolvedAddress
        case storedPhotos
    }
}

enum LocationViewAction: Equatable {
    case onAppear
    case locationRequested
    case toggleMapExpanded
    case dismissAlertButtonTapped
    case setLocationOption(LocationOption)
    case updateRegion(CoordinateRegion?)
    case userLocationAction(LocationManager.Action)
    case resolveLocation(CLLocationCoordinate2D)
    case resolveAddressFinished(Result<[GeoAddress], PlacesServiceImplementation.Error>)
}

struct LocationViewEnvironment {
    let locationManager: LocationManager
    let placeService: PlacesService
}

let locationReducer = Reducer<LocationViewState, LocationViewAction, LocationViewEnvironment>.combine(
    locationManagerReducer.pullback(
        state: \.userLocationState,
        action: /LocationViewAction.userLocationAction,
        environment: { UserLocationEnvironment(locationManager: $0.locationManager) }
    ),
    Reducer { state, action, environment in
        switch action {
        case .onAppear:
            return .merge(
                environment.locationManager
                    .create(id: LocationManagerId())
                    .map(LocationViewAction.userLocationAction),
                environment.locationManager
                    .setup(id: LocationManagerId())
                    .fireAndForget()
            )
            
        case .locationRequested:
            guard environment.locationManager.locationServicesEnabled() else {
                state.userLocationState.alert = .init(title: TextState("Location services are turned off.")) // l18n
                return .none
            }
            switch environment.locationManager.authorizationStatus() {
            case .notDetermined:
                state.userLocationState.isRequestingCurrentLocation = true
                
                return environment.locationManager
                    .requestWhenInUseAuthorization(id: LocationManagerId())
                    .fireAndForget()
                
            case .restricted:
                state.userLocationState.alert = .init(title: TextState("Please give us access to your location in settings.")) // l18n
                return .none
                
            case .denied:
                state.userLocationState.alert = .init(title: TextState("Please give us access to your location in settings.")) // l18n
                return .none
                
            case .authorizedAlways, .authorizedWhenInUse:
                return environment.locationManager
                    .requestLocation(id: LocationManagerId())
                    .fireAndForget()
                
            @unknown default:
                return .none
            }
        case .dismissAlertButtonTapped:
            state.userLocationState.alert = nil
            return .none
            
        case .toggleMapExpanded:
            state.isMapExpanded.toggle()
            return .none
        case let .setLocationOption(value):
            state.locationOption = value
            
            switch value {
            case .fromPhotos:
                return .none
            case .currentLocation:
                return Effect(value: .locationRequested)
            case .manual:
                return .none
            }
        case let .userLocationAction(userLocationAction):
            switch userLocationAction {
            case let .didUpdateLocations(locations):
                guard let region = state.userLocationState.region else {
                    return .none
                }
                return Effect(value: LocationViewAction.resolveLocation(region.center))
            default:
                return .none
            }
        case let .resolveLocation(coordinate):
            state.isResolvingAddress = true
            let clLocation = CLLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
            return environment.placeService
                .getPlacemarks(for: clLocation)
                .catchToEffect()
                .map(LocationViewAction.resolveAddressFinished)
                .cancellable(id: CancelSearchId(), cancelInFlight: true)
        case let .resolveAddressFinished(.success(address)):
            state.isResolvingAddress = false
            state.resolvedAddress = address.first ?? .init(address: .init())
            return .none
        case let .resolveAddressFinished(.failure(error)):
            state.isResolvingAddress = false
            return .none
            
        case let .updateRegion(region):
            state.userLocationState.region = region
            return .none
        }
    }
)

// MARK: - Utils
private extension LocationManager {
    func setup(id: AnyHashable) -> Effect<Never, Never> {
        set(id: id,
            activityType: .other,
            desiredAccuracy: kCLLocationAccuracyNearestTenMeters,
            distanceFilter: 100.0,
            showsBackgroundLocationIndicator: true
        )
    }
}
