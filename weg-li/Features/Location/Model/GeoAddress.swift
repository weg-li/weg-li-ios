// Created for weg-li in 2021.

import Foundation

struct GeoAddress: Equatable, Codable {
    var street: String
    var city: String
    var postalCode: String

    var isValid: Bool {
        return [street, city, postalCode]
            .allSatisfy { !$0.isEmpty }
    }
}

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

    static let empty = GeoAddress(street: "", city: "", postalCode: "")
}
