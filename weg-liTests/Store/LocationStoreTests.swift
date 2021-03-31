//
//  LocationStoreTests.swift
//  weg-liTests
//
//  Created by Malte on 30.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

@testable import weg_li
import Combine
import ComposableArchitecture
import ComposableCoreLocation
import CoreLocation
import MapKit
import XCTest

class LocationStoreTests: XCTestCase {
    
    /// if location service enabled, test that locationOption selection triggers location request and address resolve
    func test_locationOptionCurrentLocation_shouldTriggerLocationRequestAndAddressResolve() {
        var didRequestInUseAuthorization = false
        var didRequestLocation = false
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        let setSubject = PassthroughSubject<Never, Never>()
        let placesSubject = PassthroughSubject<[GeoAddress], PlacesServiceImplementation.Error>()
        
        let expectedAddress = GeoAddress(
            street: ContactState.preview.address.street,
            city: ContactState.preview.address.city,
            postalCode: ContactState.preview.address.postalCode
        )
        let env = LocationViewEnvironment(
            locationManager: .unimplemented(
                authorizationStatus: { .notDetermined },
                create: { _ in locationManagerSubject.eraseToEffect() },
                locationServicesEnabled: { true },
                requestLocation: { _ in .fireAndForget { didRequestLocation = true } },
                requestWhenInUseAuthorization: { _ in
                    .fireAndForget { didRequestInUseAuthorization = true }
                },
                set: { (_, _) -> Effect<Never, Never> in setSubject.eraseToEffect() }
            ),
            placeService: PlacesServiceMock(getPlacesSubject: placesSubject)
        )
        let store = TestStore(
            initialState: LocationViewState(storedPhotos: []),
            reducer: locationReducer,
            environment: env
        )
        
        let currentLocation = Location(
            altitude: 0,
            coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 20),
            course: 0,
            horizontalAccuracy: 0,
            speed: 0,
            timestamp: Date(timeIntervalSince1970: 1_234_567_890),
            verticalAccuracy: 0
        )
        
        store.assert(
            .send(.onAppear),
            // simulate user decision of segmented control
            .send(.setLocationOption(.currentLocation)) {
                $0.locationOption = .currentLocation
            },
            .receive(.locationRequested) {
                $0.userLocationState.isRequestingCurrentLocation = true
            },
            .do { XCTAssertTrue(didRequestInUseAuthorization) },
            // Simulate being given authorized to access location
            .do {
                locationManagerSubject.send(.didChangeAuthorization(.authorizedAlways))
            },
            .receive(.userLocationAction(.didChangeAuthorization(.authorizedAlways))),
            .do { XCTAssertTrue(didRequestLocation) },
            // Simulate finding the user's current location
            .do {
                locationManagerSubject.send(.didUpdateLocations([currentLocation]))
            },
            .receive(.userLocationAction(.didUpdateLocations([currentLocation]))) {
                $0.userLocationState.isRequestingCurrentLocation = false
                $0.userLocationState.region = CoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 10, longitude: 20),
                    span: MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            },
            .receive(.resolveLocation(CLLocationCoordinate2D(latitude: 10, longitude: 20))) {
                $0.isResolvingAddress = true
            },
            .do {
                placesSubject.send([expectedAddress])
            },
            .receive(.resolveAddressFinished(.success([expectedAddress]))) {
                $0.isResolvingAddress = false
                $0.resolvedAddress = expectedAddress
            },
            .do {
                setSubject.send(completion: .finished)
                placesSubject.send(completion: .finished)
                locationManagerSubject.send(completion: .finished)
            }
        )
    }
    
    /// if locationServices disabled, test that alert state is set
    func test_disabledLocationService_shouldSetAlert() {
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        let setSubject = PassthroughSubject<Never, Never>()
        let placesSubject = PassthroughSubject<[GeoAddress], PlacesServiceImplementation.Error>()
        
        let env = LocationViewEnvironment(
            locationManager: .unimplemented(
                authorizationStatus: { .denied },
                create: { _ in locationManagerSubject.eraseToEffect() },
                locationServicesEnabled: { false },
                set: { (_, _) -> Effect<Never, Never> in setSubject.eraseToEffect() }
            ),
            placeService: PlacesServiceMock(getPlacesSubject: placesSubject)
        )
        let store = TestStore(
            initialState: LocationViewState(storedPhotos: []),
            reducer: locationReducer,
            environment: env
        )
        
        store.assert(
            .send(.onAppear),
            // simulate user decision of segmented control
            .send(.setLocationOption(.currentLocation)) {
                $0.locationOption = .currentLocation
            },
            .receive(.locationRequested) {
                $0.userLocationState.isRequestingCurrentLocation = false
                $0.userLocationState.alert = AlertState<ReportAction>(
                    title: TextState("Location services are turned off.")
                )
            },
            .do {
                setSubject.send(completion: .finished)
                placesSubject.send(completion: .finished)
                locationManagerSubject.send(completion: .finished)
            }
        )
    }
    
    /// if locationServices disabled, test that alert state is set
    func test_deniedPermission_shouldSetAlert() {
        var didRequestInUseAuthorization = false
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        let setSubject = PassthroughSubject<Never, Never>()
        let placesSubject = PassthroughSubject<[GeoAddress], PlacesServiceImplementation.Error>()
        
        let env = LocationViewEnvironment(
            locationManager: .unimplemented(
                authorizationStatus: { .notDetermined },
                create: { _ in locationManagerSubject.eraseToEffect() },
                locationServicesEnabled: { true },
                requestWhenInUseAuthorization: { _ in
                    .fireAndForget { didRequestInUseAuthorization = true }
                },
                set: { (_, _) -> Effect<Never, Never> in setSubject.eraseToEffect() }
            ),
            placeService: PlacesServiceMock(getPlacesSubject: placesSubject)
        )
        let store = TestStore(
            initialState: LocationViewState(storedPhotos: []),
            reducer: locationReducer,
            environment: env
        )
                
        store.assert(
            .send(.onAppear),
            // simulate user decision of segmented control
            .send(.setLocationOption(.currentLocation)) {
                $0.locationOption = .currentLocation
            },
            .receive(.locationRequested) {
                $0.userLocationState.isRequestingCurrentLocation = true
            },
            .do { XCTAssertTrue(didRequestInUseAuthorization) },
            // Simulate being given authorized to access location
            .do {
                locationManagerSubject.send(.didChangeAuthorization(.denied))
            },
            .receive(.userLocationAction(.didChangeAuthorization(.denied))) {
                $0.userLocationState.alert = AlertState(
                    title: .init("Location makes this app better. Please consider giving us access.")
                )
                $0.userLocationState.isRequestingCurrentLocation = false
            },
            .do {
                setSubject.send(completion: .finished)
                placesSubject.send(completion: .finished)
                locationManagerSubject.send(completion: .finished)
            }
        )
    }
    
    func test_manuallEnteringOfAddress_updatesState_andSetsLocationToValid() {
        let store = TestStore(
            initialState: LocationViewState(
                locationOption: .manual,
                isMapExpanded: false,
                isResolvingAddress: false,
                resolvedAddress: .init(address: .init()),
                storedPhotos: [],
                userLocationState: .init()
            ),
            reducer: locationReducer,
            environment: LocationViewEnvironment(
                locationManager: LocationManager.unimplemented(),
                placeService: PlacesServiceMock()
            )
        )
        
        let newStreet = ContactState.preview.address.street
        let newPostalCode = ContactState.preview.address.postalCode
        let newCity = ContactState.preview.address.city
        
        store.assert(
            .send(.updateGeoAddressStreet(newStreet)) {
                $0.resolvedAddress.street = newStreet
                XCTAssertFalse($0.resolvedAddress.isValid)
            },
            .send(.updateGeoAddressPostalCode(newPostalCode)) {
                $0.resolvedAddress.postalCode = newPostalCode
                XCTAssertFalse($0.resolvedAddress.isValid)
            },
            .send(.updateGeoAddressCity(newCity)) {
                $0.resolvedAddress.city = newCity
                XCTAssertTrue($0.resolvedAddress.isValid)
            }
        )
    }
}
