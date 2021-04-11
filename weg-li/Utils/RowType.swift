// Created for weg-li in 2021.

import Foundation
import UIKit

enum RowType {
    case firstName, lastName, street, town, zipCode, phone

    var label: String {
        switch self {
        case .firstName: return L10n.Contact.RowType.firstName
        case .lastName: return L10n.Contact.RowType.lastName
        case .street: return L10n.Contact.RowType.street
        case .town: return L10n.Contact.RowType.city
        case .zipCode: return L10n.Contact.RowType.zipCode
        case .phone: return L10n.Contact.RowType.phone
        }
    }

    var placeholder: String {
        switch self {
        case .firstName: return "Max"
        case .lastName: return "Mustermann"
        case .street: return "Max-Brauer-Allee 23"
        case .town: return "Hamburg"
        case .zipCode: return "20095"
        case .phone: return "+491235346435"
        }
    }

    var textContentType: UITextContentType? {
        switch self {
        case .firstName: return .givenName
        case .lastName: return .familyName
        case .street: return .fullStreetAddress
        case .town: return .addressCity
        case .zipCode: return .postalCode
        case .phone: return .telephoneNumber
        }
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .phone: return .phonePad
        case .zipCode: return .numberPad
        default: return .default
        }
    }
}
