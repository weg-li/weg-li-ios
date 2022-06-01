import Combine
import ComposableArchitecture
import CoreLocation
import SharedModels

public struct PlacesServiceClient {
  public init(placemarks: @escaping (CLLocation) -> Effect<[Address], PlacesServiceError>) {
    self.placemarks = placemarks
  }
  
  public var placemarks: (CLLocation) -> Effect<[Address], PlacesServiceError>
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
