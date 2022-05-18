import ApiClient
import ComposableArchitecture
import Foundation
import SharedModels
import Styleguide
import SwiftUI
import UIApplicationClient

public struct AccountSettings: Equatable {
  @BindableState
  public var apiToken: String
  
  public init(apiToken: String) {
    self.apiToken = apiToken
  }
}

// MARK: State
public struct AccountSettingsState: Equatable {
  public let userLink = URL(string: "https://www.weg.li/user")!
  public var accountSettings: AccountSettings
  
  public var isNetworkRequestInProgress = false
  public var apiTestRequestResult: Bool?
  
  public init(accountSettings: AccountSettings) {
    self.accountSettings = accountSettings
  }
}

// MARK: Actions
public enum AccountSettingsAction: Equatable {
  case setApiKey(String)
  case openUserSettings
  case fetchNotices
  case fetchNoticesResponse(Result<[Notice], NSError>)
}

// MARK: Environment
public struct AccountSettingsEnvironment {
  public init(
    uiApplicationClient: UIApplicationClient,
    apiClient: APIClient = .live,
    noticesService: NoticesService,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.uiApplicationClient = uiApplicationClient
    self.apiClient = apiClient
    self.noticesService = noticesService
    self.mainQueue = mainQueue
  }

  public let apiClient: APIClient
  public let noticesService: NoticesService
  public let uiApplicationClient: UIApplicationClient
  public let mainQueue: AnySchedulerOf<DispatchQueue>
}

// MARK: Reducer
public let accountSettingsReducer =
Reducer<AccountSettingsState, AccountSettingsAction, AccountSettingsEnvironment>.combine(
  Reducer<AccountSettingsState, AccountSettingsAction, AccountSettingsEnvironment> {
    state, action, environment in
    switch action {
    case let .setApiKey(apiKey):
      state.accountSettings.apiToken = apiKey
      return .none
      
    case .openUserSettings:
      return environment.uiApplicationClient
        .open(state.userLink, [:])
        .fireAndForget()
      
    case .fetchNotices:
      state.isNetworkRequestInProgress = true
      
      return environment.noticesService.getNotices(state.accountSettings.apiToken)
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(AccountSettingsAction.fetchNoticesResponse)
        .eraseToEffect()
      
    case let .fetchNoticesResponse(.success(val)):
      state.isNetworkRequestInProgress = false
      state.apiTestRequestResult = true
      return .none
      
    case let .fetchNoticesResponse(.failure(error)):
      print(error)
      state.isNetworkRequestInProgress = false
      state.apiTestRequestResult = false
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
  
  let description: AttributedString? = try? AttributedString(markdown: "Hier kannst du deinen API-Token hinzufügen um die App mit deinem bestehenden Account zu verknüpfen und Anzeigen über [weg.li](https://www.weg.li) zu versenden.")
  
  public var body: some View {
    Form {
      Section(header: Text("API-Token")) {
        VStack(alignment: .leading) {
          Text(description!)
            .multilineTextAlignment(.leading)
            .foregroundColor(Color(.label))
            .font(.body)
            .padding(.bottom, .grid(1))
          
          Button(
            action: { viewStore.send(.openUserSettings) },
            label: {
              Label("Account öffnen", systemImage: "arrow.up.right")
            }
          )
          .buttonStyle(.bordered)
          .accessibilityAddTraits([.isLink])
          .padding(.bottom, .grid(4))
           
          VStack(alignment: .leading, spacing: .grid(2)) {
            TextField(
              "API-Token",
              text: viewStore.binding(
                get: \.accountSettings.apiToken,
                send: AccountSettingsAction.setApiKey
              )
            )
            .multilineTextAlignment(.leading)
            .keyboardType(.default)
            .disableAutocorrection(true)
            .submitLabel(.done)
            .textFieldStyle(.roundedBorder)

            HStack {
              Button(
                action: { viewStore.send(.fetchNotices) },
                label: {
                  HStack {
                    if viewStore.isNetworkRequestInProgress {
                      ActivityIndicator(style: .medium)
                    } else {
                      Text("API-Token testen")
                    }
                  }
                }
              )
              .disabled(viewStore.accountSettings.apiToken.isEmpty)
              .buttonStyle(.bordered)

              if let result = viewStore.apiTestRequestResult {
                Image(systemName: result ? "checkmark.circle" : "x.circle")
                  .font(.body)
                  .foregroundColor(result ? .green : .red)
              }
            }
            .padding(.bottom, .grid(2))
            
            Text("Ruft `weg.li\\api\\notices` vom Server ab")
              .multilineTextAlignment(.leading)
              .foregroundColor(Color(.secondaryLabel))
              .font(.footnote)
          }
        }
      }
      .headerProminence(.increased)
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

// MARK: Preview
struct AccountSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    AccountSettingsView(
      store: .init(
        initialState: .init(accountSettings: .init(apiToken: "")),
        reducer: accountSettingsReducer,
        environment: .init(
          uiApplicationClient: .noop,
          noticesService: .noop,
          mainQueue: .failing
        )
      )
    )
  }
}
