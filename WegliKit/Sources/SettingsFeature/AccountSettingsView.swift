import ComposableArchitecture
import Foundation
import Styleguide
import SwiftUI
import UIApplicationClient

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
  public init(uiApplicationClient: UIApplicationClient) {
    self.uiApplicationClient = uiApplicationClient
  }

  public let uiApplicationClient: UIApplicationClient
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
      Section(header: Text("API-Token")) {
        VStack(alignment: .leading) {
          Text("Hier kannst du deinen API-Token von `weg.li\\user` hinzufügen um die App mit deinem bestehenden Account zu verknüpfen und Anzeigen über `weg.li` zu versenden.")
            .multilineTextAlignment(.leading)
            .foregroundColor(Color(.label))
            .font(.body)
            .padding(.bottom, .grid(1))
          
          Button(
            action: { /* open link to account */ },
            label: {
              Label("Account öffnen", systemImage: "arrow.up.right")
            }
          )
          .buttonStyle(.bordered)
          .accessibilityAddTraits([.isLink])
          .padding(.bottom, .grid(3))
           
          VStack {
            TextField(
              "API-Token",
              text: viewStore.binding(
                get: \.accountSettings.apiKey,
                send: AccountSettingsAction.setApiKey
              )
            )
            .multilineTextAlignment(.leading)
            .keyboardType(.default)
            .disableAutocorrection(true)
            .submitLabel(.done)
            .textFieldStyle(.roundedBorder)

            Button(
              action: {},
              label: {
                HStack {
                  Text("Test API-Token")
                }
              }
            )
            .disabled(viewStore.accountSettings.apiKey.isEmpty)
            .buttonStyle(.bordered)
            
            Text("`weg.li\\user`")
              .multilineTextAlignment(.leading)
              .foregroundColor(Color(.secondaryLabel))
              .font(.footnote)
          }
        }
      }
      .headerProminence(.increased)
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
        environment: .init(uiApplicationClient: .noop)
      )
    )
  }
}
