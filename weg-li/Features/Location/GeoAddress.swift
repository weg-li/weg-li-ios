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
        return String {
            if !street.isEmpty {
                street
            }
            postalCode
            city
        }
    }

}
