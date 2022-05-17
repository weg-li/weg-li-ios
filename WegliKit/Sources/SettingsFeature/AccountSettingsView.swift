import ApiClient
import ComposableArchitecture
import Foundation
import SharedModels
import Styleguide
import SwiftUI
import UIApplicationClient

public struct GetNoticesRequest: APIRequest {
  public var queryItems: [URLQueryItem] = []
  public typealias ResponseDataType = [NoticeResponse]
  public let endpoint: Endpoint
  public let headers: HTTPHeaders?
  public let httpMethod: HTTPMethod
  public var body: Data?
  
  public init(
    endpoint: Endpoint,
    headers: HTTPHeaders? = .contentTypeApplicationJSON,
    httpMethod: HTTPMethod = .get,
    body: Data? = nil
  ) {
    self.endpoint = endpoint
    self.headers = headers
    self.httpMethod = httpMethod
    self.body = body
  }
  
  public var decoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }
}


public struct AccountSettings: Equatable {
  @BindableState
  public var apiKey: String
  
  public init(apiKey: String) {
    self.apiKey = apiKey
  }
}

// MARK: State
public struct AccountSettingsState: Equatable {
  public let userLink = URL(string: "https://www.weg.li/user")!
  public var accountSettings: AccountSettings
  
  public var isNetworkRequestInProgress = false
  
  public init(accountSettings: AccountSettings) {
    self.accountSettings = accountSettings
  }
}

// MARK: Actions
public enum AccountSettingsAction: Equatable {
  case setApiKey(String)
  case openUserSettings
  case fetchNotices
  case fetchNoticesFinished(Result<[NoticeResponse], NetworkRequestError>)
}

// MARK: Environment
public struct AccountSettingsEnvironment {
  public init(
    uiApplicationClient: UIApplicationClient,
    apiClient: APIClient = .live,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.uiApplicationClient = uiApplicationClient
    self.apiClient = apiClient
    self.mainQueue = mainQueue
  }

  public let apiClient: APIClient
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
      state.accountSettings.apiKey = apiKey
      return .none
      
    case .openUserSettings:
      return environment.uiApplicationClient
        .open(state.userLink, [:])
        .fireAndForget()
      
    case .fetchNotices:
      let endpoint = Endpoint(
        baseUrl: Endpoints.wegliAPIEndpoint,
        path: "/api/notices/\(state.accountSettings.apiKey)"
      )
      let request = GetNoticesRequest(endpoint: endpoint)
      state.isNetworkRequestInProgress = true
      
      return environment.apiClient.dispatch(request)
        .decode(
          type: GetNoticesRequest.ResponseDataType.self,
          decoder: request.decoder
        )
        .mapError { $0 as! NetworkRequestError }
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(AccountSettingsAction.fetchNoticesFinished)
        .eraseToEffect()
      
    case let .fetchNoticesFinished(.success(val)):
      print(val)
      state.isNetworkRequestInProgress = false
      return .none
      
    case let .fetchNoticesFinished(.failure(error)):
      print(error)
      state.isNetworkRequestInProgress = false
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
            action: { viewStore.send(.openUserSettings) },
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
              action: { viewStore.send(.fetchNotices) },
              label: {
                HStack {
                  if viewStore.isNetworkRequestInProgress {
                    ActivityIndicator(style: .medium)
                  } else {
                    Text("Test API-Token")
                  }
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
    .navigationBarTitleDisplayMode(.inline)
  }
}

// MARK: Preview
struct AccountSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    AccountSettingsView(
      store: .init(
        initialState: .init(accountSettings: .init(apiKey: "")),
        reducer: accountSettingsReducer,
        environment: .init(
          uiApplicationClient: .noop,
          mainQueue: .failing
        )
      )
    )
  }
}
