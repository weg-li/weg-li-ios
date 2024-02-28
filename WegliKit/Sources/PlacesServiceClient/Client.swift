import Combine
import CoreLocation
import Dependencies
import SharedModels

extension DependencyValues {
  public var placesServiceClient: PlacesServiceClient {
    get { self[PlacesServiceClient.self] }
    set { self[PlacesServiceClient.self] = newValue }
  }
}


// MARK: Client interface

public struct PlacesServiceClient {
  public init(placemarks: @escaping (CLLocation) async -> [Address]) {
    self.placemarks = placemarks
  }
  
  public var placemarks: (CLLocation) async -> [Address]
}

public struct PlacesServiceError: Equatable, Error {
  public init(message: String = "") {
    self.message = message
  }
  
  public var message = ""
}

let transformPlacemarks: ([CLPlacemark]) -> [Address] = { placemarks in
  placemarks
    .compactMap(\.postalAddress)
    .map(Address.init)
}
