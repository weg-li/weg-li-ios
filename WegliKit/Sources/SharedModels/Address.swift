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
  
  public var street: String
  public var postalCode: String
  public var city: String
  public var addition: String = ""
}

public extension Address {
  init(address: CNPostalAddress) {
    street = address.street
    postalCode = address.postalCode
    city = address.city
  }
  
  var humanReadableAddress: String {
    "\(street), \(postalCode) \(city)"
  }
  
  var isValid: Bool {
    [street, city, postalCode]
      .allSatisfy { !$0.isEmpty }
  }
}
