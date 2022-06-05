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
  
  public var mapAddressToDistrict: (Address) -> Effect<District, RegularityOfficeMapError>
  
  /// Map an Address to a District
  /// - Parameters:
  ///   - address: A valid address
  ///   - queue: a queue to perform the mapping task on
  /// - Returns: Effect which has a mapped district or an `unableToMatchRegularityOffice` error
  public func mapAddress(
    address: Address,
    on queue: AnySchedulerOf<DispatchQueue>
  ) -> Effect<District, RegularityOfficeMapError> {
    mapAddressToDistrict(address)
      .subscribe(on: queue)
      .eraseToEffect()
  }
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
