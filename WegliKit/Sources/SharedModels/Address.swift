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
    """
    \(street)
    \(postalCode) \(city)
    """
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
