// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import Foundation
import SharedModels

public extension RegulatoryOfficeMapper {
  static func live(_ districts: [District] = .all) -> Self {
    Self(
      mapAddressToDistrict: { address in
          .result {
            if let districtMAtchedByPostalCode = districts.first(where: { $0.zip == address.postalCode }) {
              return .success(districtMAtchedByPostalCode)
            } else if let districtMatchedByName = districts.first(where: { $0.name == address.city }) {
              return .success(districtMatchedByName)
            } else {
              return .failure(.unableToMatchRegularityOffice)
            }
          }
      }
    )
  }
}
