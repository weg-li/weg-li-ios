// Created for weg-li in 2021.

import ComposableArchitecture
import Contacts
import FileClient
import Foundation
import Helper
import L10n
import SharedModels

public struct ContactViewDomain: Reducer {
  public init() {}
  
  @Dependency(\.continuousClock) var clock
  @Dependency(\.fileClient) var fileClient
  
  public struct State: Equatable {
    @BindingState public var contact: Contact
    @PresentationState public var alert: AlertState<Action.Alert>?
    
    public init(contact: Contact = .empty) {
      self.contact = contact
    }
  }
  
  @CasePathable
  public enum Action: Equatable {
    case alert(PresentationAction<Alert>)
    case contact(ContactDomain.Action)
    case onResetContactDataButtonTapped
    case onResetContactConfirmButtonTapped
    case dismissAlert
    case onDisappear
    
    public enum Alert: Equatable, Sendable {
      case onResetButtonTapped
    }
  }
  
  enum CancelID { case debounce }
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.contact, action: /Action.contact) {
      ContactDomain()
    }
    
    Reduce<State, Action> { state, action in
      switch action {
      case .alert:
        return .none
        
      case .contact:
        let contact = state.contact
        return .run { _ in
          try await withTaskCancellation(id: CancelID.debounce, cancelInFlight: true) {
            try await clock.sleep(for: .seconds(0.3))
            try await fileClient.saveContactSettings(contact)
          }
        }

      case .onResetContactDataButtonTapped:
        state.alert = .resetContactDataAlert
        return .none
      case .onResetContactConfirmButtonTapped:
        state.contact = .empty
        return .send(.dismissAlert)
      case .dismissAlert:
        state.alert = nil
        return .none
      case .onDisappear:
        return .none
      }
    }
  }
}


public struct ContactDomain: Reducer {
  public init() {}
  
  public typealias State = Contact
  
  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
  }
}

// MARK: Helper

public extension AlertState where Action == ContactViewDomain.Action.Alert {
  static let resetContactDataAlert = Self(
    title: { TextState(L10n.Contact.Alert.title) },
    actions: {
      ButtonState(
        role: .destructive,
        action: .onResetButtonTapped,
        label: { TextState(L10n.Contact.Alert.reset) }
      )
      
      ButtonState(role: .cancel) {
        TextState(L10n.cancel)
      }
    }
  )
}

public extension ContactViewDomain.State {
  static let empty = Self(contact: .empty)

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
    )
  )
}
