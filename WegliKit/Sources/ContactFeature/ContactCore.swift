// Created for weg-li in 2021.

import ComposableArchitecture
import Contacts
import Foundation
import Helper
import L10n
import SharedModels

public struct ContactViewDomain: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public init(
      contact: Contact = .empty,
      alert: AlertState<Action>? = nil
    ) {
      self.contact = contact
      self.alert = alert
    }
    
    @BindableState public var contact: Contact
    @BindableState public var alert: AlertState<Action>?
    
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
  }
  
  public enum Action: Equatable {
    case contact(ContactDomain.Action)
    case onResetContactDataButtonTapped
    case onResetContactConfirmButtonTapped
    case dismissAlert
    case onDisappear
  }
  
  public var body: some ReducerProtocol<State, Action> {
    Scope(state: \.contact, action: /Action.contact) {
      ContactDomain()
    }
    
    Reduce<State, Action> { state, action in
      switch action {
      case .contact:
        return .none
      case .onResetContactDataButtonTapped:
        state.alert = .resetContactDataAlert
        return .none
      case .onResetContactConfirmButtonTapped:
        state.contact = .empty
        return Effect(value: .dismissAlert)
      case .dismissAlert:
        state.alert = nil
        return .none
      case .onDisappear:
        return .none
      }
    }
  }
}


public struct ContactDomain: ReducerProtocol {
  public init() {}
  
  public typealias State = Contact
  
  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
  }
  
  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
  }
}

// MARK: Helper

public extension AlertState where Action == ContactViewDomain.Action {
  static let resetContactDataAlert = Self(
    title: TextState(L10n.Contact.Alert.title),
    primaryButton: .destructive(
      TextState(L10n.Contact.Alert.reset),
      action: .send(.onResetContactConfirmButtonTapped)
    ),
    secondaryButton: .cancel(.init(L10n.cancel), action: .send(.dismissAlert))
  )
}

public extension ContactViewDomain.State {
  static let empty = Self(contact: .empty, alert: nil)

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
