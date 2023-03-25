import ComposableArchitecture
import Foundation

public struct AccountSettingsDomain: ReducerProtocol {
  public init() {}
  
  @Dependency(\.keychainClient) var keychainClient
  @Dependency(\.applicationClient) var applicationClient
  @Dependency(\.continuousClock) var clock
  
  public struct State: Equatable {
    public var accountSettings: AccountSettings
    
    public var link: Link?
    
    public init(accountSettings: AccountSettings) {
      self.accountSettings = accountSettings
    }
    
    public struct Link: Identifiable, Equatable {
      public let id: String
      public let url: URL

      public init(url: URL) {
        self.url = url
        self.id = url.absoluteString
      }
    }
  }
  
  public enum Action: Equatable {
    case setApiToken(String)
    case onGoToProfileButtonTapped
    case onCreateProfileButtonTapped
    case dismissSheet
  }
  
  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case let .setApiToken(token):
      state.accountSettings.apiToken = token
      return .fireAndForget {
        enum CancelID {}
        
        await withTaskCancellation(id: CancelID.self, cancelInFlight: true) {
          try? await clock.sleep(for: .seconds(0.1))
          _ = await keychainClient.setApiToken(token)
        }
      }

    case .onGoToProfileButtonTapped:
      state.link = .init(url: URL(string: "https://www.weg.li/user")!)
      return .none
      
    case .onCreateProfileButtonTapped:
      state.link = .init(url: URL(string: "https://www.weg.li")!)
      return .none
      
    case .dismissSheet:
      state.link = nil
      return .none
    }
  }
}

public struct AccountSettings: Equatable {
  @BindingState public var apiToken: String
  
  public init(apiToken: String) {
    self.apiToken = apiToken
  }
}
