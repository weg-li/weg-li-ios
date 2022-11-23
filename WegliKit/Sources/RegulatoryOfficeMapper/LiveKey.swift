// Created for weg-li in 2021.

import Combine
import Foundation
import Dependencies
import SharedModels

extension RegulatoryOfficeMapper: DependencyKey {
  public static var liveValue: RegulatoryOfficeMapper = live()
  
  public static func live(_ districts: [District] = .all) -> Self {
    Self(
      mapAddressToDistrict: { address in
        let task = Task(priority: .userInitiated) {
          if let districtMAtchedByPostalCode = districts.first(where: { $0.zip == address.postalCode }) {
            return districtMAtchedByPostalCode
          } else if let districtMatchedByName = districts.first(where: { $0.name == address.city }) {
            return districtMatchedByName
          } else {
            throw RegularityOfficeMapError.unableToMatchRegularityOffice
          }
        }
        return try await task.value
      }
    )
  }
}
