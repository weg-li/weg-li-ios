// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import Foundation

struct RegulatoryOfficeMapper {
    var mapAddressToDistrict: (GeoAddress) -> Effect<District, RegularityOfficeMapError>
}

extension RegulatoryOfficeMapper {
    static func live(_ districts: [District] = .all) -> Self {
        Self(
            mapAddressToDistrict: { address in
                .result {
                    if let districtMAtchedByPostalCode = districts.first(where: { $0.zipCode == address.postalCode }) {
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

    static let noop = Self(
        mapAddressToDistrict: { _ in .none }
    )
}

struct RegularityOfficeMapError: Error, Equatable {
    var message: String = ""
}

extension RegularityOfficeMapError {
    static let unableToMatchRegularityOffice = RegularityOfficeMapError(message: "Unable to match address")
}
