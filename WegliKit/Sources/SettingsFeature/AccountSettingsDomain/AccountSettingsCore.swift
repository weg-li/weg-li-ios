import ComposableArchitecture
import Foundation

public struct AccountSettingsDomain: ReducerProtocol {
  public init() {}
  
  @Dependency(\.keychainClient) var keychainClient
  @Dependency(\.applicationClient) var applicationClient
  @Dependency(\.continuousClock) var clock
  
  public let userLink = URL(string: "https://www.weg.li/user")!
  
  public struct State: Equatable {
    public var accountSettings: AccountSettings
    
    public var isNetworkRequestInProgress = false
    public var apiTestRequestResult: Bool?
    
    public init(accountSettings: AccountSettings) {
      self.accountSettings = accountSettings
    }
  }
  
  public enum Action: Equatable {
    case setApiToken(String)
    case openUserSettings
  }
  
  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case let .setApiToken(token):
      state.accountSettings.apiToken = token
      return .fireAndForget {
        enum CancelID {}
        
        await withTaskCancellation(id: CancelID.self, cancelInFlight: true) {
          try? await clock.sleep(for: .seconds(0.3))
          _ = await keychainClient.setApiToken(token)
        }
      }

    case .openUserSettings:
      return .fireAndForget(priority: .userInitiated) {
        _ = await applicationClient.open(userLink, [:])
      }
    }
  }
}

public struct AccountSettings: Equatable {
  @BindableState
  public var apiToken: String
  
  public init(apiToken: String) {
    self.apiToken = apiToken
  }
}
