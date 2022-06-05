import ComposableArchitecture
import Contacts
import Foundation

public struct Address: Equatable, Codable {
  public init(
    street: String = "",
    postalCode: String = "",
    city: String = "",
    addition: String = ""
  ) {
    self.street = street
    self.postalCode = postalCode
    self.city = city
    self.addition = addition
  }
  
  @BindableState public var street: String
  @BindableState public var postalCode: String
  @BindableState public var city: String
  @BindableState public var addition = ""
}

public extension Address {
  init(address: CNPostalAddress) {
    self.street = address.street
    self.postalCode = address.postalCode
    self.city = address.city
  }
  
  @StringBuilder func humanReadableAddress() -> String {
    if !street.isEmpty {
      street
    }
    if !postalCode.isEmpty, !city.isEmpty {
      "\(postalCode) \(city)"
    }
  }
    
  var humanReadableCity: String {
    let formatter = CNPostalAddressFormatter()
    
    let address = CNMutablePostalAddress()
    address.postalCode = postalCode
    address.city = city
    
    return formatter.string(from: address)
  }
  
  var isValid: Bool {
    [street, city, postalCode]
      .allSatisfy { !$0.isEmpty }
  }
}

@resultBuilder
enum StringBuilder {
  static func buildBlock(_ components: String...) -> String {
    let filtered = components.filter { $0 != "" }
    return filtered.joined(separator: "\n")
  }
  
  static func buildOptional(_ component: String?) -> String {
    component ?? ""
  }
}
