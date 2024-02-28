import ComposableArchitecture
import Foundation

public struct AccountSettingsDomain: Reducer {
  public init() {}
  
  @Dependency(\.keychainClient) var keychainClient
  @Dependency(\.applicationClient) var applicationClient
  @Dependency(\.continuousClock) var clock
  
  public struct State: Equatable {
    @PresentationState var alert: AlertState<Action.Alert>?
    public var accountSettings: AccountSettings
    
    @PresentationState public var link: Link.State?
    
    public init(accountSettings: AccountSettings) {
      self.accountSettings = accountSettings
    }
  }
  
  @CasePathable
  public enum Action: Equatable, Sendable {
    case onAppear
    case setApiToken(String)
    case onGoToProfileButtonTapped
    case onCreateProfileButtonTapped
    case dismissSheet
    case link(PresentationAction<Link.Action>)
    
    enum Alert: Equatable {}
  }
  
  enum CancelID { case debounce }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.accountSettings.apiToken = keychainClient.getToken() ?? ""
        return .none
        
      case let .setApiToken(token):
        state.accountSettings.apiToken = token
        return .run { _ in
          await withTaskCancellation(id: CancelID.debounce, cancelInFlight: true) {
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
    
      case .link:
        return .none
      }
    }
    .ifLet(\.$link, action: \.link) {
      Link()
    }
  }
}

public struct AccountSettings: Equatable {
  @BindingState public var apiToken: String
  
  public init(apiToken: String) {
    self.apiToken = apiToken
  }
}

@Reducer
public struct Link {
  public struct State: Equatable {
    public let id: String
    public let url: URL
    
    public init(url: URL) {
      self.url = url
      self.id = url.absoluteString
    }
  }
  
  public enum Action: Sendable {
    case dismiss
  }
  
  public var body: some Reducer<State, Action> {
    Reduce { _, action in
      switch action {
      case .dismiss:
        return .none
      }
    }
  }
}
