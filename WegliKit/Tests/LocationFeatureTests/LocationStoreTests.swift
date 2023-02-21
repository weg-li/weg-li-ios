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
    let didRequestInUseAuthorization = ActorIsolated(false)
    let didRequestLocation = ActorIsolated(false)
    let locationObserver = AsyncStream<LocationManager.Action>.streamWithContinuation()
    
    let expectedAddress = Address(
      street: Contact.preview.address.street,
      postalCode: Contact.preview.address.postalCode,
      city: Contact.preview.address.city
    )
    
    let store = TestStore(
      initialState: LocationDomain.State(),
      reducer: LocationDomain(),
      prepareDependencies: { values in
        values.locationManager.authorizationStatus = { .notDetermined }
        values.locationManager.delegate = { locationObserver.stream }
        values.locationManager.locationServicesEnabled = { true }
        values.locationManager.requestLocation = { await didRequestLocation.setValue(true) }
        values.locationManager.requestWhenInUseAuthorization = { await didRequestInUseAuthorization.setValue(true) }
        values.placesServiceClient = PlacesServiceClient(placemarks: { _ in [expectedAddress] })
        values.applicationClient = .previewValue
        values.mainRunLoop = .immediate
      }
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
    
    let task = await store.send(.onAppear)
    // simulate user decision of segmented control
    await store.send(.setLocationOption(.currentLocation)) {
      $0.isResolvingAddress = true
      $0.locationOption = .currentLocation
    }
    await store.receive(.locationRequested) {
      $0.isRequestingCurrentLocation = true
    }
    
    await didRequestInUseAuthorization.withValue { XCTAssertTrue($0) }
    // Simulate being given authorized to access location
    locationObserver.continuation.yield(.didChangeAuthorization(.authorizedAlways))
    
    await store.receive(.locationManager(.didChangeAuthorization(.authorizedAlways)))
    await didRequestLocation.withValue { XCTAssertTrue($0) }
    // Simulate finding the user's current location
    locationObserver.continuation.yield(.didUpdateLocations([currentLocation]))
    
    await store.receive(.locationManager(.didUpdateLocations([currentLocation]))) {
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
    locationObserver.continuation.yield(.didUpdateLocations([locationWithVeryLittleDistanceChangeFromFirst]))
    
    await store.receive(.locationManager(.didUpdateLocations([locationWithVeryLittleDistanceChangeFromFirst])))
    
    locationObserver.continuation.finish()
    await task.cancel()
  }
  
  /// if location service enabled, test that locationOption selection triggers location request and address resolve
  func test_locationOptionCurrentLocation_shouldTriggerLocationRequestAndAddressResolve_whenANewLocationIsFurtherAway() async {
    let didRequestInUseAuthorization = ActorIsolated(false)
    let didRequestLocation = ActorIsolated(false)
    let locationObserver = AsyncStream<LocationManager.Action>.streamWithContinuation()
    
    let expectedAddress = Address(
      street: Contact.preview.address.street,
      postalCode: Contact.preview.address.postalCode,
      city: Contact.preview.address.city
    )
        
    let store = TestStore(
      initialState: LocationDomain.State(),
      reducer: LocationDomain(),
      prepareDependencies: { values in
        values.locationManager.authorizationStatus = { .notDetermined }
        values.locationManager.delegate = { locationObserver.stream }
        values.locationManager.locationServicesEnabled = { true }
        values.locationManager.requestLocation = { await didRequestLocation.setValue(true) }
        values.locationManager.requestWhenInUseAuthorization = { await didRequestInUseAuthorization.setValue(true) }
        values.placesServiceClient = PlacesServiceClient(placemarks: { _ in [expectedAddress] })
        values.applicationClient = .previewValue
        values.mainRunLoop = .immediate
      }
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
    
    let task = await store.send(.onAppear)
    // simulate user decision of segmented control
    await store.send(.setLocationOption(.currentLocation)) {
      $0.isResolvingAddress = true
      $0.locationOption = .currentLocation
    }
    await store.receive(.locationRequested) {
      $0.isRequestingCurrentLocation = true
    }
    await didRequestInUseAuthorization.withValue { XCTAssertTrue($0) }
    // Simulate being given authorized to access location
    locationObserver.continuation.yield(.didChangeAuthorization(.authorizedAlways))
    
    await store.receive(.locationManager(.didChangeAuthorization(.authorizedAlways)))
    await didRequestLocation.withValue { XCTAssertTrue($0) }
    // Simulate finding the user's current location
    locationObserver.continuation.yield(.didUpdateLocations([currentLocation]))
    
    await store.receive(.locationManager(.didUpdateLocations([currentLocation]))) {
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
    locationObserver.continuation.yield(.didUpdateLocations([locationWithBiggerDistanceChangeFromFirst]))
    
    await store.receive(.locationManager(.didUpdateLocations([locationWithBiggerDistanceChangeFromFirst]))) {
      $0.region = .init(center: locationWithBiggerDistanceChangeFromFirst.coordinate)
    }
    await store.receive(.resolveLocation(locationWithBiggerDistanceChangeFromFirst.coordinate)) {
      $0.isResolvingAddress = true
    }
    await store.receive(.resolveAddressFinished(.success([expectedAddress]))) {
      $0.isResolvingAddress = false
      $0.resolvedAddress = expectedAddress
    }
    
    locationObserver.continuation.finish()
    await task.cancel()
  }
  
  /// if locationServices disabled, test that alert state is set
  func test_disabledLocationService_shouldSetAlert() async {
    let locationObserver = AsyncStream<LocationManager.Action>.streamWithContinuation()
    
    let store = TestStore(
      initialState: LocationDomain.State(),
      reducer: LocationDomain(),
      prepareDependencies: { values in
        values.locationManager = .unimplemented
        values.locationManager.authorizationStatus = { .denied }
        values.locationManager.delegate = { locationObserver.stream }
        values.locationManager.locationServicesEnabled = { false }
        values.locationManager.set = { @Sendable _ in }
        values.placesServiceClient = .noop
        values.applicationClient = .previewValue
        values.mainRunLoop = .immediate
      }
    )
    
    let task = await store.send(.onAppear)
    // simulate user decision of segmented control
    await store.send(.setLocationOption(.currentLocation)) {
      $0.isResolvingAddress = true
      $0.locationOption = .currentLocation
    }
    await store.receive(.locationRequested) {
      $0.isRequestingCurrentLocation = false
      $0.alert = .servicesOff
    }
    
    locationObserver.continuation.finish()
    await task.cancel()
  }
  
  /// if locationServices disabled, test that alert state is set
  func test_deniedPermission_shouldSetAlert() async {
    let didRequestInUseAuthorization = ActorIsolated(false)
    let locationObserver = AsyncStream<LocationManager.Action>.streamWithContinuation()

    let store = TestStore(
      initialState: LocationDomain.State(),
      reducer: LocationDomain(),
      prepareDependencies: { values in
        values.locationManager = .unimplemented
        values.locationManager.authorizationStatus = { .notDetermined }
        values.locationManager.delegate = { locationObserver.stream }
        values.locationManager.locationServicesEnabled = { true }
        values.locationManager.requestWhenInUseAuthorization = { await didRequestInUseAuthorization.setValue(true) }
        values.locationManager.set = { @Sendable _ in }
        values.placesServiceClient = .noop
        values.applicationClient = .previewValue
        values.mainRunLoop = .immediate
      }
    )
    let task = await store.send(.onAppear)
    // simulate user decision of segmented control
    await store.send(.setLocationOption(.currentLocation)) {
      $0.isResolvingAddress = true
      $0.locationOption = .currentLocation
    }
    await store.receive(.locationRequested) {
      $0.isRequestingCurrentLocation = true
    }
    await didRequestInUseAuthorization.withValue { XCTAssertTrue($0) }
    // Simulate being given authorized to access location
    locationObserver.continuation.yield(.didChangeAuthorization(.denied))
    
    await store.receive(.locationManager(.didChangeAuthorization(.denied))) {
      $0.alert = .provideAuth
      $0.isRequestingCurrentLocation = false
    }
    
    locationObserver.continuation.finish()
    await task.cancel()
  }
  
  func test_manuallEnteringOfAddress_updatesState_andSetsLocationToValid() async {
    let store = TestStore(
      initialState: LocationDomain.State(
        locationOption: .manual,
        isMapExpanded: false,
        isResolvingAddress: false,
        resolvedAddress: .init(address: .init())
      ),
      reducer: LocationDomain(),
      prepareDependencies: { values in
        values.locationManager = .unimplemented
        values.placesServiceClient = .noop
        values.applicationClient = .previewValue
        values.mainRunLoop = .immediate
      }
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
      initialState: LocationDomain.State(
        locationOption: .manual,
        isMapExpanded: false,
        isResolvingAddress: false,
        resolvedAddress: .init(address: .init())
      ),
      reducer: LocationDomain(),
      prepareDependencies: { values in
        values.locationManager = .unimplemented
        values.placesServiceClient = .noop
        values.applicationClient = uiApplicationClient
        values.mainRunLoop = .immediate
      }
    )
    
    await store.send(.onGoToSettingsButtonTapped)
    await openedUrl.withValue({ url in
      XCTAssertEqual(url, URL(string: settingsURL))
    })
    
  }
}
