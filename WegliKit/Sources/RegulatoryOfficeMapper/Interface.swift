import Combine
import ComposableArchitecture
import Foundation
import SharedModels

public struct RegulatoryOfficeMapper {
  internal init(
    mapAddressToDistrict: @escaping (Address) -> Effect<District, RegularityOfficeMapError>
  ) {
    self.mapAddressToDistrict = mapAddressToDistrict
  }
  
  /// Map an Address to a District
  public var mapAddressToDistrict: (Address) -> Effect<District, RegularityOfficeMapError>
}

// MARK: RegularityOfficeMapError

public struct RegularityOfficeMapError: Error, Equatable {
  public init(message: String = "") {
    self.message = message
  }
  
  public let message: String
}

public extension RegularityOfficeMapError {
  static let unableToMatchRegularityOffice = RegularityOfficeMapError(message: "Unable to match address")
}


// MARK: All districts from JSON

public extension Array where Element == District {
  static let all = Bundle.module.decode(
    [District].self, from: "districts.json",
    dateDecodingStrategy: .iso8601,
    keyDecodingStrategy: .convertFromSnakeCase
  )
}
