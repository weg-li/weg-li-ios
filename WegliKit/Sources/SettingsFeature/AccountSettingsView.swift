import Foundation

import SwiftUI
import ComposableArchitecture

public struct AccountSettings: Equatable {
  @BindableState
  public var apiKey: String
  
  public init(apiKey: String) {
    self.apiKey = apiKey
  }
}

// MARK: State
public struct AccountSettingsState: Equatable {
  public var accountSettings: AccountSettings
  
  public init(accountSettings: AccountSettings) {
    self.accountSettings = accountSettings
  }
}

// MARK: Actions
public enum AccountSettingsAction: Equatable {
  case setApiKey(String)
}

// MARK: Environment
public struct AccountSettingsEnvironment {
  public init() {}
}

// MARK: Reducer
public let accountSettingsReducer =
Reducer<AccountSettingsState, AccountSettingsAction, AccountSettingsEnvironment>.combine(
  Reducer<AccountSettingsState, AccountSettingsAction, AccountSettingsEnvironment> {
    state, action, environment in
    switch action {
    case let .setApiKey(apiKey):
      state.accountSettings.apiKey = apiKey
      return .none
    }
  }
)

fileprivate typealias S = AccountSettingsState
fileprivate typealias A = AccountSettingsAction

// MARK:- View
public struct AccountSettingsView: View {
  let store: Store<AccountSettingsState, AccountSettingsAction>
  @ObservedObject var viewStore: ViewStore<AccountSettingsState, AccountSettingsAction>
  
  public init(store: Store<AccountSettingsState, AccountSettingsAction>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  public var body: some View {
    Form {
      Section {
        TextField(
          "API KEY",
          text: viewStore.binding(
            get: \.accountSettings.apiKey,
            send: AccountSettingsAction.setApiKey
          )
        )
        .multilineTextAlignment(.leading)
        .keyboardType(.default)
        .disableAutocorrection(true)
        .submitLabel(.done)
        .textFieldStyle(.plain)
      }
    }
  }
}

// MARK: Preview
struct AccountSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    AccountSettingsView(
      store: .init(
        initialState: .init(accountSettings: .init(apiKey: "")),
        reducer: accountSettingsReducer,
        environment: .init()
      )
    )
  }
}
