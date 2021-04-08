// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import Foundation

struct RegularityOfficeMapError: Error, Equatable {
    var message: String = ""
}

struct RegulatoryOfficeMapper {
    static let districts = Bundle.main.decode([District].self, from: "districts.json")
    
    var mapAddressToDistrict: (GeoAddress) -> Effect<District, RegularityOfficeMapError>
}

extension RegulatoryOfficeMapper {
    static let live = Self(
        mapAddressToDistrict: { geoAddress in
            .result {
                if let districtMAtchedByPostalCode = districts.first(where: { $0.zipCode == geoAddress.postalCode }) {
                    return .success(districtMAtchedByPostalCode)
                } else if let districtMatchedByName = districts.first(where: { $0.name == geoAddress.city }) {
                    return .success(districtMatchedByName)
                } else {
                    return .failure(RegularityOfficeMapError())
                }
            }
        }
    )
    
    static let noop = Self(
        mapAddressToDistrict: { _ in return .none }
    )
}
