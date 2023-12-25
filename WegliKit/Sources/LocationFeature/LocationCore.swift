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

@Reducer
public struct LocationDomain {
  public init() {}
  
  @Dependency(\.placesServiceClient) public var placesServiceClient
  @Dependency(\.locationManager) public var locationManager
  @Dependency(\.applicationClient) public var applicationClient
  
  public struct State: Equatable {
    public init(
      alert: AlertState<Action>? = nil,
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
    
    @PresentationState public var alert: AlertState<Action>?
    public var locationOption: LocationOption = .fromPhotos
    public var isMapExpanded = false
    public var isResolvingAddress = false
    public var resolvedAddress: Address = .init()
    public var pinCoordinate: CLLocationCoordinate2D?
    public var isRequestingCurrentLocation = false
    public var region: CoordinateRegion?
  }
  
  public enum Action: Equatable {
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
  
  public var body: some ReducerOf<Self> {
    Reduce<State, Action> { state, action in
      switch action {
      case .onAppear:
        return .merge(
          .run { send in
            for await event in locationManager.delegate() {
              await send(.locationManager(event))
            }
          }
          .cancellable(id: LocationManagerId()),
          .run { _ in
            await locationManager.setup()
          }
        )
        
      case .locationRequested:
        guard locationManager.locationServicesEnabled() else {
          state.alert = .servicesOff
          return .none
        }
        switch locationManager.authorizationStatus() {
        case .notDetermined:
          state.isRequestingCurrentLocation = true
          return .run { _ in
            await locationManager.requestWhenInUseAuthorization()
          }
          
        case .restricted:
          state.alert = .goToSettingsAlert
          return .none
          
        case .denied:
          state.alert = .goToSettingsAlert
          return .none
          
        case .authorizedAlways, .authorizedWhenInUse:
          return .run { _ in
            await locationManager.startUpdatingLocation()
          }
          
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
          return .send(.locationRequested)
        case .manual:
          state.isResolvingAddress = false
          return .none
        }
        
      case let .locationManager(.didUpdateLocations(locations)):
        guard let location = locations.first else {
          return .none
        }
        
        guard let region = state.region else {
          let region = CoordinateRegion(center: location.coordinate)
          state.region = region
          return .send(.resolveLocation(region.center.asCLLocationCoordinate2D))
        }
        
        guard
          region.asMKCoordinateRegion.center.distance(from: location.coordinate) > 100
        else {
          return .none
        }
        
        state.region = .init(center: location.coordinate)
        return .send(.resolveLocation(location.coordinate))
        
      case .locationManager(let locationAciton):
        switch locationAciton {
        case .didChangeAuthorization(.authorizedAlways),
            .didChangeAuthorization(.authorizedWhenInUse):
          if state.isRequestingCurrentLocation {
            return .run { _ in
              await locationManager.requestLocation()
            }
          }
          
          return .none
          
        case .didChangeAuthorization(.denied):
          if state.isRequestingCurrentLocation {
            state.isRequestingCurrentLocation = false
            state.alert = .provideAuth
          }
          return .none
          
        case .didUpdateLocations:
          state.isRequestingCurrentLocation = false
          return .none
          
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
        
        return .run { send in
          await withTaskCancellation(id: CancelId.search, cancelInFlight: true) {
            await send(
              .resolveAddressFinished(
                TaskResult {
                  await placesServiceClient.placemarks(clLocation)
                }
              )
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
        return .run { _ in
          guard let url = await URL(string: applicationClient.openSettingsURLString()) else { return }
          _ = await applicationClient.open(url, [:])
        }
      }
    }
  }
}


public enum UserLocationError: Error {
  case accessDenied
  case locationNotFound
}

// TCA uses Hashable structs for identifying effects
struct LocationManagerId: Hashable {}
enum CancelId { case search  }

// MARK: - Utils

extension LocationManager {
  /// Configures the LocationManager
  func setup() async {
    await set(
      activityType: .otherNavigation,
      allowsBackgroundLocationUpdates: false,
      desiredAccuracy: kCLLocationAccuracyNearestTenMeters,
      distanceFilter: 100,
      pausesLocationUpdatesAutomatically: true,
      showsBackgroundLocationIndicator: true
    )
  }
}

public extension AlertState where Action == LocationDomain.Action {
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


// MARK: - Dependencies

enum LocationManagerKey: DependencyKey {
  static let liveValue = LocationManager.live
  static let testValue = LocationManager.live 
}

public extension DependencyValues {
  var locationManager: LocationManager {
    get { self[LocationManagerKey.self] }
    set { self[LocationManagerKey.self] = newValue }
  }
}
