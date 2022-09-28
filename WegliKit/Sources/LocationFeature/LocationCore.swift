// Created for weg-li in 2021.

import ComposableArchitecture
import ComposableCoreLocation
import Foundation
import L10n
import MapKit
import PlacesServiceClient
import SharedModels
import SwiftUI
import UIApplicationClient

public enum UserLocationError: Error {
  case accessDenied
  case locationNotFound
}

// TCA uses Hashable structs for identifying effects
struct LocationManagerId: Hashable {}
enum CancelSearchId {}

// MARK: - Location Core

public struct LocationViewState: Equatable, Codable {
  public init(
    alert: AlertState<LocationViewAction>? = nil,
    locationOption: LocationOption = .fromPhotos,
    isMapExpanded: Bool = false,
    isResolvingAddress: Bool = false,
    resolvedAddress: Address = .init(),
    pinCoordinate: CLLocationCoordinate2D? = nil,
    isRequestingCurrentLocation: Bool = false,
    region: CoordinateRegion? = nil
  ) {
    self.alert = alert
    self.locationOption = locationOption
    self.isMapExpanded = isMapExpanded
    self.isResolvingAddress = isResolvingAddress
    self.resolvedAddress = resolvedAddress
    self.pinCoordinate = pinCoordinate
    self.region = region
    self.isRequestingCurrentLocation = isRequestingCurrentLocation
  }
  
  public var alert: AlertState<LocationViewAction>?
  public var locationOption: LocationOption = .fromPhotos
  public var isMapExpanded = false
  public var isResolvingAddress = false
  public var resolvedAddress: Address = .init()
  public var pinCoordinate: CLLocationCoordinate2D?
  public var isRequestingCurrentLocation = false
  public var region: CoordinateRegion?
  
  private enum CodingKeys: String, CodingKey {
    case locationOption
    case isMapExpanded
    case resolvedAddress
    case region
  }
}

public enum LocationViewAction: Equatable {
  case onAppear
  case locationRequested
  case onToggleMapExpandedTapped
  case onGoToSettingsButtonTapped
  case onDismissAlertButtonTapped
  case setLocationOption(LocationOption)
  case updateRegion(CoordinateRegion?)
  case locationManager(LocationManager.Action)
  case resolveLocation(CLLocationCoordinate2D)
  case resolveAddressFinished(TaskResult<[Address]>)
  case updateGeoAddressStreet(String)
  case updateGeoAddressCity(String)
  case updateGeoAddressPostalCode(String)
  case setResolvedLocation(CLLocationCoordinate2D?)
  case setPinCoordinate(CLLocationCoordinate2D?)
}

public struct LocationViewEnvironment {
  public init(
    locationManager: LocationManager,
    placeService: PlacesServiceClient,
    uiApplicationClient: UIApplicationClient,
    mainRunLoop: AnySchedulerOf<DispatchQueue>
  ) {
    self.locationManager = locationManager
    self.placeService = placeService
    self.uiApplicationClient = uiApplicationClient
    self.mainRunLoop = mainRunLoop
  }
  
  public var locationManager: ComposableCoreLocation.LocationManager
  public var placeService: PlacesServiceClient
  public var uiApplicationClient: UIApplicationClient
  public var mainRunLoop: AnySchedulerOf<DispatchQueue>
}

/// LocationReducer handling setup, location widget actions, alert presentation and reverse geo coding the user location.
public let locationReducer = Reducer<LocationViewState, LocationViewAction, LocationViewEnvironment> { state, action, environment in
  switch action {
  case .onAppear:
    return .merge(
      environment.locationManager
        .create(id: LocationManagerId())
        .map(LocationViewAction.locationManager),
      environment.locationManager
        .setup()
        .fireAndForget()
    )
    
  case .locationRequested:
    guard environment.locationManager.locationServicesEnabled() else {
      state.alert = .servicesOff
      return .none
    }
    switch environment.locationManager.authorizationStatus() {
    case .notDetermined:
      state.isRequestingCurrentLocation = true
      return environment.locationManager
        .requestWhenInUseAuthorization()
        .fireAndForget()
      
    case .restricted:
      state.alert = .goToSettingsAlert
      return .none
      
    case .denied:
      state.alert = .goToSettingsAlert
      return .none
      
    case .authorizedAlways, .authorizedWhenInUse:
      return environment.locationManager
        .startUpdatingLocation()
        .fireAndForget()
      
    @unknown default:
      return .none
    }
    
  case .onDismissAlertButtonTapped:
    state.alert = nil
    return .none
    
  case .onToggleMapExpandedTapped:
    state.isMapExpanded.toggle()
    return .none
    
  case let .setLocationOption(value):
    state.locationOption = value
    switch value {
    case .fromPhotos:
      state.isResolvingAddress = false
      return .none
    case .currentLocation:
      state.isResolvingAddress = true
      return Effect(value: .locationRequested)
    case .manual:
      state.isResolvingAddress = false
      return .none
    }
    
  case let .locationManager(locationManagerAction):
    switch locationManagerAction {
    case .didChangeAuthorization(.authorizedAlways),
         .didChangeAuthorization(.authorizedWhenInUse):
      if state.isRequestingCurrentLocation {
        return environment.locationManager
          .requestLocation()
          .fireAndForget()
      }
      return .none
      
    case .didChangeAuthorization(.denied):
      if state.isRequestingCurrentLocation {
        state.isRequestingCurrentLocation = false
        state.alert = .provideAuth
      }
      return .none
      
    case let .didUpdateLocations(locations):
      state.isRequestingCurrentLocation = false
      guard let location = locations.first else {
        return .none
      }
      
      if let region = state.region {
        guard
          location.coordinate != region.center.asCLLocationCoordinate2D,
          region.asMKCoordinateRegion.center.distance(from: location.coordinate) > 100
        else {
          return .none
        }
        state.region = CoordinateRegion(center: location.coordinate)
        return Effect(value: LocationViewAction.resolveLocation(location.coordinate))
      } else {
        state.region = CoordinateRegion(center: location.coordinate)
        return Effect(value: LocationViewAction.resolveLocation(location.coordinate))
      }
            
    case let .didFailWithError(error):
      debugPrint(error.localizedDescription)
      return .none
      
    default:
      return .none
    }
    
  case let .resolveLocation(coordinate): // reverse geo code coordinate to address
    state.isResolvingAddress = true
    let clLocation = CLLocation(
      latitude: coordinate.latitude,
      longitude: coordinate.longitude
    )
    
    return .task {
      await withTaskCancellation(id: CancelSearchId.self, cancelInFlight: true) {
        await .resolveAddressFinished(
          TaskResult {
            await environment.placeService.placemarks(clLocation)
          }
        )
      }
    }
        
  case let .resolveAddressFinished(.success(address)):
    state.isResolvingAddress = false
    state.resolvedAddress = address.first ?? .init()
    return .none
  case let .resolveAddressFinished(.failure(error)):
    debugPrint(error)
    state.alert = .reverseGeoCodingFailed
    state.isResolvingAddress = false
    return .none
    
  case let .updateRegion(region):
    state.region = region
    return .none
    
  case let .updateGeoAddressStreet(street):
    state.resolvedAddress.street = street
    return .none
  case let .updateGeoAddressCity(city):
    state.resolvedAddress.city = city
    return .none
  case let .updateGeoAddressPostalCode(postalCode):
    state.resolvedAddress.postalCode = postalCode
    return .none
    
  case .setResolvedLocation:
    return .none
    
  case let .setPinCoordinate(coordinate):
    if state.locationOption == .currentLocation {
      state.pinCoordinate = coordinate
    }
    return .none
    
  case .onGoToSettingsButtonTapped:
    return .fireAndForget {
      guard let url = await URL(string: environment.uiApplicationClient.openSettingsURLString()) else { return }
      _ = await environment.uiApplicationClient.open(url, [:])
    }
  }
}

// MARK: - Utils

extension LocationManager {
  /// Configures the LocationManager
  func setup() -> Effect<Never, Never> {
    set(
      .init(
        activityType: .otherNavigation,
        allowsBackgroundLocationUpdates: false,
        desiredAccuracy: kCLLocationAccuracyNearestTenMeters,
        distanceFilter: 100,
        pausesLocationUpdatesAutomatically: true,
        showsBackgroundLocationIndicator: true
      )
    )
  }
}

public extension AlertState where Action == LocationViewAction {
  static let goToSettingsAlert = Self(
    title: TextState(L10n.Location.Alert.provideAccessToLocationService),
    primaryButton: .default(
      TextState(L10n.Settings.title),
      action: .send(.onGoToSettingsButtonTapped)
    ),
    secondaryButton: .default(TextState("OK"))
  )
  
  static let provideAuth = Self(title: TextState(L10n.Location.Alert.provideAuth))
  static let servicesOff = Self(title: TextState(L10n.Location.Alert.serviceIsOff))
  static let reverseGeoCodingFailed = Self(title: TextState("Reverse geo coding failed"))
  static let provideAccessToLocationService = Self(
    title: TextState(L10n.Location.Alert.provideAccessToLocationService)
  )
}

extension CLLocationCoordinate2D {
  /// Returns distance from coordianate in meters.
  /// - Parameter from: coordinate which will be used as end point.
  /// - Returns: Returns distance in meters.
  func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
    let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
    let to = CLLocation(latitude: latitude, longitude: longitude)
    return from.distance(from: to)
  }
}
