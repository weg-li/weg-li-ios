// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import Foundation

struct RegularityOfficeMapError: Error, Equatable {
    var message: String = ""
}

struct OfficeMapperInput {
    let geoAddress: GeoAddress
    let districts: [District]

    init(_ geoAddress: GeoAddress, _ districts: [District] = .all) {
        self.geoAddress = geoAddress
        self.districts = districts
    }
}

struct RegulatoryOfficeMapper {
    var mapAddressToDistrict: (OfficeMapperInput) -> Effect<District, RegularityOfficeMapError>
}

extension RegulatoryOfficeMapper {
    static let live = Self(
        mapAddressToDistrict: { input in
            .result {
                if let districtMAtchedByPostalCode = input.districts.first(where: { $0.zipCode == input.geoAddress.postalCode }) {
                    return .success(districtMAtchedByPostalCode)
                } else if let districtMatchedByName = input.districts.first(where: { $0.name == input.geoAddress.city }) {
                    return .success(districtMatchedByName)
                } else {
                    return .failure(RegularityOfficeMapError())
                }
            }
        }
    )

    static let noop = Self(
        mapAddressToDistrict: { _ in .none }
    )
}
