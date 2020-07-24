//
//  User.swift
//  weg-li
//
//  Created by Malte Bünz on 05.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Foundation

struct Contact {
    struct Address {
        let street: String
        let zipCode: String
        let town: String
    }
    let firstName: String
    let name: String
    let address: Address
    let phone: String
}

extension Contact {
    var isValid: Bool {
        [firstName, name, address.street, address.town, address.zipCode, phone].allSatisfy { !$0.isEmpty }
    }
}

extension Contact.Address {
    var humanReadableAddress: String {
        return String {
            if !street.isEmpty {
                street
            }
            zipCode
            town
        }
    }
}

extension Address {
    var humanReadableAddress: String {
        return String {
            if !street.isEmpty {
                self.street
            }
            self.postalCode
            self.city
        }
    }
}
