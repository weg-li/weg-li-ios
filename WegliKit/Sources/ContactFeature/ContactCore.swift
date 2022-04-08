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
    alert: AlertState<ContactStateAction>? = nil
  ) {
    self.contact = contact
    self.alert = alert
  }
  
  @BindableState
  public var contact: Contact
  @BindableState
  public var alert: AlertState<ContactStateAction>?
  
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

public enum ContactStateAction: Equatable {
  case contact(ContactAction)
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
public let contactViewReducer = Reducer<ContactState, ContactStateAction, ContactEnvironment>.combine(
  contactReducer.pullback(
    state: \.contact,
    action: /ContactStateAction.contact,
    environment: { _ in .init() }
  ),
  Reducer { state, action, _ in
    switch action {
    case .contact:
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
)

public enum ContactAction: BindableAction, Equatable {
  case binding(BindingAction<Contact>)
}

public let contactReducer = Reducer<Contact, ContactAction, ContactEnvironment> { state, action, _ in
  switch action {
  case .binding:
    return .none
  }
}
.binding()


// MARK: Helper
public extension AlertState where Action == ContactStateAction {
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
        city: RowType.city.placeholder
      ),
      phone: RowType.phone.placeholder
    ),
    alert: nil
  )
}
