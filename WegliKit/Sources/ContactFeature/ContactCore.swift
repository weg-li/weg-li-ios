// Created for weg-li in 2021.

import ComposableArchitecture
import Contacts
import Foundation
import Helper
import L10n
import SharedModels

public struct ContactState: Equatable, Codable {
  public init(
    contact: Contact = .empty,
    alert: AlertState<ContactAction>? = nil
  ) {
    self.contact = contact
    self.alert = alert
  }
  
  public var contact: Contact
  public var alert: AlertState<ContactAction>?
  
  public var isValid: Bool {
    [
      contact.firstName,
      contact.name,
      contact.address.street,
      contact.address.city
    ].allSatisfy { !$0.isEmpty }
    && contact.address.postalCode.isNumeric
    && contact.address.postalCode.count == 5
  }
  
  enum CodingKeys: String, CodingKey {
    case contact
  }
}

// MARK: - Action

public enum ContactAction: Equatable {
  case firstNameChanged(String)
  case lastNameChanged(String)
  case phoneChanged(String)
  case streetChanged(String)
  case zipCodeChanged(String)
  case townChanged(String)
  case dateOfBirthChanged(String)
  case addressAdditionChanged(String)
  case resetContactDataButtonTapped
  case resetContactConfirmButtonTapped
  case dismissAlert
  case onDisappear
}

// MARK: - Environment

public struct ContactEnvironment {
  public init() {}
}

/// Reducer handling ContactView actions
public let contactReducer = Reducer<ContactState, ContactAction, ContactEnvironment> { state, action, _ in
  switch action {
  case let .firstNameChanged(firstName):
    state.contact.firstName = firstName
    return .none
  case let .lastNameChanged(lastName):
    state.contact.name = lastName
    return .none
  case let .phoneChanged(phone):
    state.contact.phone = phone
    return .none
  case let .streetChanged(street):
    state.contact.address.street = street
    return .none
  case let .townChanged(town):
    state.contact.address.city = town
    return .none
  case let .zipCodeChanged(zipCode):
    state.contact.address.postalCode = zipCode
    return .none
  case let .dateOfBirthChanged(date):
    state.contact.dateOfBirth = date
    return .none
  case let .addressAdditionChanged(addition):
    state.contact.address.addition = addition
    return .none
  case .resetContactDataButtonTapped:
    state.alert = .resetContactDataAlert
    return .none
  case .resetContactConfirmButtonTapped:
    state.contact = .empty
    return Effect(value: .dismissAlert)
  case .dismissAlert:
    state.alert = nil
    return .none
  case .onDisappear:
    return .none
  }
}

// MARK: Helper
public extension AlertState where Action == ContactAction {
  static let resetContactDataAlert = Self(
    title: TextState(L10n.Contact.Alert.title),
    primaryButton: .destructive(
      TextState(L10n.Contact.Alert.reset),
      action: .send(.resetContactConfirmButtonTapped)
    ),
    secondaryButton: .cancel(.init(L10n.cancel), action: .send(.dismissAlert))
  )
}

public extension ContactState {
  static let empty = Self(
    contact: .empty, alert: nil
  )
  
  static let preview = Self(
    contact: .init(
      firstName: RowType.firstName.placeholder,
      name: RowType.lastName.placeholder,
      address: .init(
        street: RowType.street.placeholder,
        postalCode: RowType.zipCode.placeholder,
        city: RowType.town.placeholder
      ),
      phone: RowType.phone.placeholder
    ),
    alert: nil
  )
}
