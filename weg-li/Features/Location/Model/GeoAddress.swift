//
//  GeoAddress.swift
//  weg-li
//
//  Created by Malte on 30.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

import Foundation

extension GeoAddress {
    init(address: Address) {
        self.street = address.street
        self.city = address.city
        self.postalCode = address.postalCode
    }
    
    var humanReadableAddress: String {
        let allParameterAreNotEmpty = [street, postalCode, city].allSatisfy { !$0.isEmpty }
        guard allParameterAreNotEmpty else { return "" }
        return "\(street), \(postalCode) \(city)"
    }
}
