// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import Foundation
import SharedModels

public extension RegulatoryOfficeMapper {
  static func live(_ districts: [District] = .all) -> Self {
    Self(
      mapAddressToDistrict: { address in
          .future { promise in
            mapperQueue.async {
              if let districtMAtchedByPostalCode = districts.first(where: { $0.zip == address.postalCode }) {
                promise(.success(districtMAtchedByPostalCode))
              } else if let districtMatchedByName = districts.first(where: { $0.name == address.city }) {
                promise(.success(districtMatchedByName))
              } else {
                promise(.failure(.unableToMatchRegularityOffice))
              }
            }
          }
      }
    )
  }
}

let mapperQueue = DispatchQueue(
  label: "li.weg.iosclient.RegulatoryOfficeMapper",
  qos: .userInitiated,
  attributes: .concurrent
)
