import ComposableArchitecture
import Foundation

public struct Contact: Equatable, Codable {
  public init(
    firstName: String = "",
    name: String = "",
    address: Address = .init(),
    phone: String = "",
    dateOfBirth: String = ""
  ) {
    self.firstName = firstName
    self.name = name
    self.address = address
    self.phone = phone
    self.dateOfBirth = dateOfBirth
  }
  
  @BindableState public var firstName: String
  @BindableState public var name: String
  @BindableState public var address: Address
  @BindableState public var phone: String
  @BindableState public var dateOfBirth: String
}


// MARK: Helper
public extension Contact {
  static let empty = Self(
    firstName: "",
    name: "",
    address: .init(),
    phone: ""
  )
  
  static let preview = Self(
    firstName: RowType.firstName.placeholder,
    name: RowType.lastName.placeholder,
    address: .init(
      street: RowType.street.placeholder,
      postalCode: RowType.zipCode.placeholder,
      city: RowType.city.placeholder
    ),
    phone: RowType.phone.placeholder,
    dateOfBirth: RowType.dateOfBirth.placeholder
  )
}

public extension SharedModels.Contact {
  var fullName: String {
    let formatter = PersonNameComponentsFormatter()
    
    var components = PersonNameComponents()
    components.givenName = firstName
    components.familyName = name
    
    return formatter.string(from: components)
  }
  
  var humanReadableContact: String {
    var output = fullName
    if !phone.isEmpty {
      output.append("\nTelefonnummer: \(phone)")
    }
    if !dateOfBirth.isEmpty {
      output.append("\nGeburtstag: \(dateOfBirth)")
    }
    return output
  }
}
