// Created for weg-li in 2021.

import Foundation

extension GeoAddress {
    init(address: Address) {
        street = address.street
        city = address.city
        postalCode = address.postalCode
    }

    var humanReadableAddress: String {
        let allParameterAreNotEmpty = [street, postalCode, city].allSatisfy { !$0.isEmpty }
        guard allParameterAreNotEmpty else { return "" }
        return "\(street), \(postalCode) \(city)"
    }
}
