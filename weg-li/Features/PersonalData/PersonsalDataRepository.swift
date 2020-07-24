//
//  PersonsalDataRepository.swift
//  weg-li
//
//  Created by Malte Bünz on 04.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import Foundation

final class PersonsalDataRepository {
    var contact: Contact {
        get {
            Contact(
                firstName: firstName,
                name: name,
                address: .init(street: street, zipCode: zipCode, town: town),
                phone: phone)
            }
        set {
            self.firstName = newValue.firstName
            self.name = newValue.name
            self.street = newValue.address.street
            self.zipCode = newValue.address.zipCode
            self.town = newValue.address.town
            self.phone = newValue.phone
        }
    }

    @UserDefault(key: "personalData_firstName", defaultValue: "")
    private var firstName: String

    @UserDefault(key: "personalData_name", defaultValue: "")
    private var name: String

    @UserDefault(key: "personalData_street", defaultValue: "")
    private var street: String

    @UserDefault(key: "personalData_zip", defaultValue: "")
    private var zipCode: String

    @UserDefault(key: "personalData_town", defaultValue: "")
    private var town: String

    @UserDefault(key: "personalData_phone", defaultValue: "")
    private var phone: String
}
