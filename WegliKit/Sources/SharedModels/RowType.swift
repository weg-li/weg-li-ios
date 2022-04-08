// Created for weg-li in 2021.

import Foundation
import L10n
import UIKit

public enum RowType {
  case firstName, lastName, street, town, zipCode, phone, dateOfBirth, addressAddition
  
  public var label: String {
    switch self {
    case .firstName: return L10n.Contact.RowType.firstName
    case .lastName: return L10n.Contact.RowType.lastName
    case .street: return L10n.Contact.RowType.street
    case .town: return L10n.Contact.RowType.city
    case .zipCode: return L10n.Contact.RowType.zipCode
    case .phone: return L10n.Contact.RowType.phone
    case .dateOfBirth: return L10n.Contact.Row.dateOfBirth
    case .addressAddition: return L10n.Contact.Row.addressAddition
    }
  }
  
  public var placeholder: String {
    switch self {
    case .firstName: return "Max"
    case .lastName: return "Mustermann"
    case .street: return "Max-Brauer-Allee 23"
    case .town: return "Hamburg"
    case .zipCode: return "20095"
    case .phone: return "+491235346435"
    case .dateOfBirth: return "01.01.2001"
    case .addressAddition: return "Hinterhaus"
    }
  }
  
  public var textContentType: UITextContentType? {
    switch self {
    case .firstName: return .givenName
    case .lastName: return .familyName
    case .street: return .streetAddressLine1
    case .town: return .addressCity
    case .zipCode: return .postalCode
    case .phone: return .telephoneNumber
    case .dateOfBirth, .addressAddition: return nil
    }
  }
  
  public var keyboardType: UIKeyboardType {
    switch self {
    case .phone: return .phonePad
    case .zipCode: return .numberPad
    case .dateOfBirth: return .numbersAndPunctuation
    default: return .default
    }
  }
}
