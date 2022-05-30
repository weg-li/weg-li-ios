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
  public var accountSettings: AccountSettings
  
  public var isNetworkRequestInProgress = false
  public var apiTestRequestResult: Bool?
  
  public init(accountSettings: AccountSettings) {
    self.accountSettings = accountSettings
  }
}

// MARK: Actions
public enum AccountSettingsAction: Equatable {
  case setApiToken(String)
  case openUserSettings
  case fetchNotices
  case fetchNoticesResponse(Result<[Notice], ApiError>)
}

// MARK: Environment
public struct AccountSettingsEnvironment {
  public init(
    uiApplicationClient: UIApplicationClient,
    apiClient: APIClient = .live,
    wegliService: WegliAPIService,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.uiApplicationClient = uiApplicationClient
    self.apiClient = apiClient
    self.wegliService = wegliService
    self.mainQueue = mainQueue
  }

  public let apiClient: APIClient
  public let wegliService: WegliAPIService
  public let uiApplicationClient: UIApplicationClient
  public let mainQueue: AnySchedulerOf<DispatchQueue>
  
  public let userLink = URL(string: "https://www.weg.li/user")!
}

// MARK: Reducer
public let accountSettingsReducer =
Reducer<AccountSettingsState, AccountSettingsAction, AccountSettingsEnvironment>.combine(
  Reducer<AccountSettingsState, AccountSettingsAction, AccountSettingsEnvironment> {
    state, action, environment in
    switch action {
    case let .setApiToken(token):
      state.accountSettings.apiToken = token
      return .none
      
    case .openUserSettings:
      return environment.uiApplicationClient
        .open(environment.userLink, [:])
        .fireAndForget()
      
    case .fetchNotices:
      state.isNetworkRequestInProgress = true
      
      return environment.wegliService.getNotices()
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
  
  let description: AttributedString? = try? AttributedString(markdown: "Füge Deinen API-Token hinzu um die App mit deinem bestehenden Account zu verknüpfen und Anzeigen über [weg.li](https://www.weg.li) zu versenden. Du findest den API-Token in deinem Profil")
  
  public var body: some View {
    UITextField.appearance().clearButtonMode = .whileEditing
    return Form {
      Section(header: Label("API-Token", systemImage: "bolt.fill")) {
        VStack(alignment: .leading) {
          VStack(alignment: .leading, spacing: .grid(3)) {
            TextField(
              "",
              text: viewStore.binding(
                get: \.accountSettings.apiToken,
                send: AccountSettingsAction.setApiToken
              )
            )
            .placeholder(when: viewStore.state.accountSettings.apiToken.isEmpty, placeholder: {
              Text("API-Token")
                .italic()
                .foregroundColor(Color(.lightGray))
            })
            .lineLimit(1)
            .font(.body.monospaced())
            .keyboardType(.default)
            .foregroundColor(.white)
            .padding(.grid(3))
            .background(Color.gitHubBannerBackground)
            .accentColor(Color.green)
            .clipShape(RoundedRectangle(
              cornerRadius: .grid(2), style: .circular)
            )
            .overlay(
              RoundedRectangle(cornerRadius: .grid(2))
                .stroke(Color(.label), lineWidth: 2)
            )
            .disableAutocorrection(true)
            .submitLabel(.done)
            .padding(.vertical, .grid(4))

            Button(
              action: { viewStore.send(.fetchNotices) },
              label: {
                HStack {
                  if viewStore.isNetworkRequestInProgress {
                    ActivityIndicator(style: .medium, color: .gray)
                  } else {
                    Text("API-Token testen")
                  }
                }
                .frame(maxWidth: .infinity, minHeight: 44)
              }
            )
            .disabled(viewStore.accountSettings.apiToken.isEmpty)
            .buttonStyle(.bordered)
            
            HStack(alignment: .center) {
              Text("Ruft `weg.li\\api\\notices` vom Server ab")
                .multilineTextAlignment(.leading)
                .foregroundColor(Color(.secondaryLabel))
                .font(.footnote)
              
              if let result = viewStore.apiTestRequestResult {
                Image(systemName: result ? "checkmark.circle" : "x.circle")
                  .font(.body)
                  .foregroundColor(result ? .green : .red)
              }
            }
            .padding(.vertical, .grid(2))
            
            VStack(alignment: .leading) {
              Text(description!)
                .multilineTextAlignment(.leading)
                .foregroundColor(Color(.secondaryLabel))
                .font(.subheadline)
                .padding(.vertical, .grid(1))
              
              Button(
                action: { viewStore.send(.openUserSettings) },
                label: {
                  Label("Profil öffnen", systemImage: "arrow.up.right")
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
              )
              .buttonStyle(.bordered)
              .accessibilityAddTraits([.isLink])
              
            }
            .padding(.grid(2))
            .overlay(
              RoundedRectangle(cornerRadius: 4)
                .stroke(Color(.lightGray), lineWidth: 1)
            )
          }
        }
      }
      .headerProminence(.increased)
    }
    .navigationBarTitle("Account", displayMode: .inline)
  }
}

private extension View {
  func placeholder<Content: View>(
    when shouldShow: Bool,
    alignment: Alignment = .leading,
    @ViewBuilder placeholder: () -> Content) -> some View {
      
      ZStack(alignment: alignment) {
        placeholder().opacity(shouldShow ? 1 : 0)
        self
      }
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
          wegliService: .noop,
          mainQueue: .failing
        )
      )
    )
  }
}
