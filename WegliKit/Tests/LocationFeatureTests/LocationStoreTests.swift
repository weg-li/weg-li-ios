// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import CoreLocation
import LocationFeature
import MapKit
import PlacesServiceClient
import SharedModels
import UIApplicationClient
import XCTest

@MainActor
final class LocationStoreTests: XCTestCase {
  /// if location service enabled, test that locationOption selection triggers location request and address resolve
  func test_locationOptionCurrentLocation_shouldTriggerLocationRequestAndAddressResolve() async {
    var didRequestInUseAuthorization = false
    var didRequestLocation = false
    let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
    let setSubject = PassthroughSubject<Never, Never>()
    
    let expectedAddress = Address(
      street: Contact.preview.address.street,
      postalCode: Contact.preview.address.postalCode,
      city: Contact.preview.address.city
    )
    
    func env() -> LocationViewEnvironment {
      var locationManager: LocationManager = .failing
      locationManager.authorizationStatus = { .notDetermined }
      locationManager.delegate = { locationManagerSubject.eraseToEffect() }
      locationManager.locationServicesEnabled = { true }
      locationManager.requestLocation = { .fireAndForget { didRequestLocation = true } }
      locationManager.requestWhenInUseAuthorization = { .fireAndForget { didRequestInUseAuthorization = true } }
      locationManager.set = { _ in setSubject.eraseToEffect() }
      
      return LocationViewEnvironment(
        locationManager: locationManager,
        placeService: PlacesServiceClient(placemarks: { _ in [expectedAddress] }),
        uiApplicationClient: .noop, mainRunLoop: .immediate
      )
    }
    
    let store = TestStore(
      initialState: LocationViewState(),
      reducer: locationReducer,
      environment: env()
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
    
    await store.send(.onAppear)
    await store.send(.setLocationOption(.currentLocation)) {
      $0.isResolvingAddress = true
      $0.locationOption = .currentLocation
    }
    await store.receive(.locationRequested) {
      $0.isRequestingCurrentLocation = true
    }
    XCTAssertTrue(didRequestInUseAuthorization)
    // Simulate being given authorized to access location
    locationManagerSubject.send(.didChangeAuthorization(.authorizedAlways))
    
    await store.receive(.locationManager(.didChangeAuthorization(.authorizedAlways)))
    XCTAssertTrue(didRequestLocation)
    // Simulate finding the user's current location
    locationManagerSubject.send(.didUpdateLocations([currentLocation]))
    
    await store.receive(.locationManager(.didUpdateLocations([currentLocation]))) {
      $0.isRequestingCurrentLocation = false
      $0.region = CoordinateRegion(
        center: currentLocation.coordinate
      )
    }
    await store.receive(.resolveLocation(currentLocation.coordinate))
    await store.receive(.resolveAddressFinished(.success([expectedAddress]))) {
      $0.isResolvingAddress = false
      $0.resolvedAddress = expectedAddress
    }
    
    let locationWithVeryLittleDistanceChangeFromFirst = Location(
      altitude: 0,
      coordinate: CLLocationCoordinate2D(latitude: 10.00000000001, longitude: 20.000000004),
      course: 0,
      horizontalAccuracy: 0,
      speed: 0,
      timestamp: Date(timeIntervalSince1970: 1_234_567_890),
      verticalAccuracy: 0
    )
    locationManagerSubject.send(.didUpdateLocations([locationWithVeryLittleDistanceChangeFromFirst]))
    
    await store.receive(.locationManager(.didUpdateLocations([locationWithVeryLittleDistanceChangeFromFirst])))
    
    setSubject.send(completion: .finished)
    locationManagerSubject.send(completion: .finished)
  }
  
  /// if location service enabled, test that locationOption selection triggers location request and address resolve
  func test_locationOptionCurrentLocation_shouldTriggerLocationRequestAndAddressResolve_whenANewLocationIsFurtherAway() async {
    var didRequestInUseAuthorization = false
    var didRequestLocation = false
    let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
    let setSubject = PassthroughSubject<Never, Never>()
    
    let expectedAddress = Address(
      street: Contact.preview.address.street,
      postalCode: Contact.preview.address.postalCode,
      city: Contact.preview.address.city
    )
    
    var env = LocationViewEnvironment(
      locationManager: .failing,
      placeService: PlacesServiceClient(placemarks: { _ in [expectedAddress] }),
      uiApplicationClient: .noop, mainRunLoop: .immediate
    )
    env.locationManager.authorizationStatus = { .notDetermined }
    env.locationManager.delegate = { locationManagerSubject.eraseToEffect() }
    env.locationManager.locationServicesEnabled = { true }
    env.locationManager.requestLocation = { .fireAndForget { didRequestLocation = true } }
    env.locationManager.requestWhenInUseAuthorization = {
        .fireAndForget { didRequestInUseAuthorization = true }
    }
    env.locationManager.set = { _ in setSubject.eraseToEffect() }
    
    let store = TestStore(
      initialState: LocationViewState(),
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
    
    await store.send(.onAppear)
    // simulate user decision of segmented control
    await store.send(.setLocationOption(.currentLocation)) {
      $0.isResolvingAddress = true
      $0.locationOption = .currentLocation
    }
    await store.receive(.locationRequested) {
      $0.isRequestingCurrentLocation = true
    }
    XCTAssertTrue(didRequestInUseAuthorization)
    // Simulate being given authorized to access location
    locationManagerSubject.send(.didChangeAuthorization(.authorizedAlways))
    
    await store.receive(.locationManager(.didChangeAuthorization(.authorizedAlways)))
    XCTAssertTrue(didRequestLocation)
    // Simulate finding the user's current location
    locationManagerSubject.send(.didUpdateLocations([currentLocation]))
    
    await store.receive(.locationManager(.didUpdateLocations([currentLocation]))) {
      $0.isRequestingCurrentLocation = false
      $0.region = CoordinateRegion(
        center: currentLocation.coordinate
      )
    }
    await store.receive(.resolveLocation(currentLocation.coordinate))
    await store.receive(.resolveAddressFinished(.success([expectedAddress]))) {
      $0.isResolvingAddress = false
      $0.resolvedAddress = expectedAddress
    }
    
    let locationWithBiggerDistanceChangeFromFirst = Location(
      altitude: 0,
      coordinate: CLLocationCoordinate2D(latitude: 10.02, longitude: 20.03),
      course: 0,
      horizontalAccuracy: 0,
      speed: 0,
      timestamp: Date(timeIntervalSince1970: 1_234_567_890),
      verticalAccuracy: 0
    )
    locationManagerSubject.send(.didUpdateLocations([locationWithBiggerDistanceChangeFromFirst]))
    
    await store.receive(.locationManager(.didUpdateLocations([locationWithBiggerDistanceChangeFromFirst]))) {
      $0.isRequestingCurrentLocation = false
      $0.region = .init(center: locationWithBiggerDistanceChangeFromFirst.coordinate)
    }
    await store.receive(.resolveLocation(locationWithBiggerDistanceChangeFromFirst.coordinate)) {
      $0.isResolvingAddress = true
    }
    await store.receive(.resolveAddressFinished(.success([expectedAddress]))) {
      $0.isResolvingAddress = false
      $0.resolvedAddress = expectedAddress
    }
    
    setSubject.send(completion: .finished)
    locationManagerSubject.send(completion: .finished)
  }
  
  /// if locationServices disabled, test that alert state is set
  func test_disabledLocationService_shouldSetAlert() {
    let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
    let setSubject = PassthroughSubject<Never, Never>()
    
    var env = LocationViewEnvironment(
      locationManager: .failing,
      placeService: .noop,
      uiApplicationClient: .noop, mainRunLoop: .immediate
    )
    env.locationManager.authorizationStatus = { .denied }
    env.locationManager.delegate = { locationManagerSubject.eraseToEffect() }
    env.locationManager.locationServicesEnabled = { false }
    env.locationManager.set = { _ in setSubject.eraseToEffect() }
    
    let store = TestStore(
      initialState: LocationViewState(),
      reducer: locationReducer,
      environment: env
    )
    
    store.send(.onAppear)
    // simulate user decision of segmented control
    store.send(.setLocationOption(.currentLocation)) {
      $0.isResolvingAddress = true
      $0.locationOption = .currentLocation
    }
    store.receive(.locationRequested) {
      $0.isRequestingCurrentLocation = false
      $0.alert = .servicesOff
    }
    setSubject.send(completion: .finished)
    locationManagerSubject.send(completion: .finished)
  }
  
  /// if locationServices disabled, test that alert state is set
  func test_deniedPermission_shouldSetAlert() {
    var didRequestInUseAuthorization = false
    let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
    let setSubject = PassthroughSubject<Never, Never>()
    
    var env = LocationViewEnvironment(
      locationManager: .failing,
      placeService: .noop,
      uiApplicationClient: .noop, mainRunLoop: .immediate
    )
    env.locationManager.authorizationStatus = { .notDetermined }
    env.locationManager.delegate = { locationManagerSubject.eraseToEffect() }
    env.locationManager.locationServicesEnabled = { true }
    env.locationManager.requestWhenInUseAuthorization = { .fireAndForget { didRequestInUseAuthorization = true } }
    env.locationManager.set = { _ in setSubject.eraseToEffect() }
    
    let store = TestStore(
      initialState: LocationViewState(),
      reducer: locationReducer,
      environment: env
    )
    store.send(.onAppear)
    // simulate user decision of segmented control
    store.send(.setLocationOption(.currentLocation)) {
      $0.isResolvingAddress = true
      $0.locationOption = .currentLocation
    }
    store.receive(.locationRequested) {
      $0.isRequestingCurrentLocation = true
    }
    XCTAssertTrue(didRequestInUseAuthorization)
    // Simulate being given authorized to access location
    locationManagerSubject.send(.didChangeAuthorization(.denied))
    
    store.receive(.locationManager(.didChangeAuthorization(.denied))) {
      $0.alert = .provideAuth
      $0.isRequestingCurrentLocation = false
    }
    
    setSubject.send(completion: .finished)
    locationManagerSubject.send(completion: .finished)
  }
  
  func test_manuallEnteringOfAddress_updatesState_andSetsLocationToValid() async {
    let store = TestStore(
      initialState: LocationViewState(
        locationOption: .manual,
        isMapExpanded: false,
        isResolvingAddress: false,
        resolvedAddress: .init(address: .init())
      ),
      reducer: locationReducer,
      environment: LocationViewEnvironment(
        locationManager: .failing,
        placeService: .noop,
        uiApplicationClient: .noop, mainRunLoop: .immediate
      )
    )
    
    let newStreet = Contact.preview.address.street
    let newPostalCode = Contact.preview.address.postalCode
    let newCity = Contact.preview.address.city
    
    await store.send(.updateGeoAddressStreet(newStreet)) {
      $0.resolvedAddress.street = newStreet
      XCTAssertFalse($0.resolvedAddress.isValid)
    }
    await store.send(.updateGeoAddressPostalCode(newPostalCode)) {
      $0.resolvedAddress.postalCode = newPostalCode
      XCTAssertFalse($0.resolvedAddress.isValid)
    }
    await store.send(.updateGeoAddressCity(newCity)) {
      $0.resolvedAddress.city = newCity
      XCTAssertTrue($0.resolvedAddress.isValid)
    }
  }
  
  func test_goToSettingsAction_shouldOpenSettingsURL() async {
    let openedUrl: ActorIsolated<URL?> = .init(nil)
    let settingsURL = "settings:weg-li//weg-li/settings"
    let uiApplicationClient: UIApplicationClient = .init(
      open: { @Sendable url, _ in
        await openedUrl.setValue(url)
        return true
      },
      openSettingsURLString: { settingsURL }
    )
    
    let store = TestStore(
      initialState: LocationViewState(
        locationOption: .manual,
        isMapExpanded: false,
        isResolvingAddress: false,
        resolvedAddress: .init(address: .init())
      ),
      reducer: locationReducer,
      environment: LocationViewEnvironment(
        locationManager: .failing,
        placeService: .noop,
        uiApplicationClient: uiApplicationClient, mainRunLoop: .immediate
      )
    )
    
    await store.send(.onGoToSettingsButtonTapped)
    await openedUrl.withValue({ url in
      XCTAssertEqual(url, URL(string: settingsURL))
    })
    
  }
}
