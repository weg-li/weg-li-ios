import Combine
import ComposableArchitecture
import Foundation
import SharedModels

public struct RegulatoryOfficeMapper {
  init(
    mapAddressToDistrict: @escaping (Address) async throws -> District
  ) {
    self.mapAddressToDistrict = mapAddressToDistrict
  }
  
  public var mapAddressToDistrict: (Address) async throws -> District
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
