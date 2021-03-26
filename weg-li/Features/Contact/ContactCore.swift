//
//  ContactCore.swift
//  weg-li
//
//  Created by Malte on 10.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

import ComposableArchitecture
import Contacts
import Foundation

struct ContactState: Equatable, Codable {
    struct Address: Equatable, Codable {
        var street: String = ""
        var postalCode: String = ""
        var city: String = ""
    }
    var firstName: String = ""
    var name: String = ""
    var address: Address = .init()
    var phone: String = ""
    
    var isValid = false
}

extension ContactState {
    static var empty: ContactState {
        ContactState(
            firstName: "",
            name: "",
            address: .init(),
            phone: ""
        )
    }
    
    static var preview: ContactState {
        ContactState(
            firstName: RowType.firstName.placeholder,
            name: RowType.lastName.placeholder,
            address: .init(
                street: RowType.street.placeholder,
                postalCode: RowType.zipCode.placeholder,
                city: RowType.town.placeholder
            ),
            phone: RowType.phone.placeholder
        )
    }
}

extension ContactState.Address {
    init(address: CNPostalAddress) {
        street = address.street
        postalCode = address.postalCode
        city = address.city
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

// MARK: - Action
enum ContactAction: Equatable {
    case firstNameChanged(String)
    case lastNameChanged(String)
    case phoneChanged(String)
    case streetChanged(String)
    case zipCodeChanged(String)
    case townChanged(String)
    case isContactValid
}

// MARK: - Environment
struct ContactEnvironment {}

let contactReducer =
    Reducer<ContactState, ContactAction, ContactEnvironment> { state, action, _ in
        switch action {
        case let .firstNameChanged(firstName):
            state.firstName = firstName
            return Effect(value: .isContactValid)
        case let .lastNameChanged(lastName):
            state.name = lastName
            return Effect(value: .isContactValid)
        case let .phoneChanged(phone):
            state.phone = phone
            return Effect(value: .isContactValid)
        case let .streetChanged(street):
            state.address.street = street
            return Effect(value: .isContactValid)
        case let .townChanged(town):
            state.address.city = town
            return Effect(value: .isContactValid)
        case let .zipCodeChanged(zipCode):
            state.address.postalCode = zipCode
            return Effect(value: .isContactValid)
        case .isContactValid:
            state.isValid = [
                state.firstName,
                state.name,
                state.address.street,
                state.address.city,
                state.address.postalCode,
                state.phone
            ].allSatisfy { !$0.isEmpty }
            return .none
        }
    }
