// Created for weg-li in 2021.

import Foundation
import UIKit

enum RowType {
    case firstName, lastName, street, town, zipCode, phone

    var label: String {
        switch self {
        case .firstName: return "Vorname"
        case .lastName: return "Nachname"
        case .street: return "Strasse"
        case .town: return "Stadt"
        case .zipCode: return "PLZ"
        case .phone: return "Telefon"
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
        default: return .default
        }
    }
}
