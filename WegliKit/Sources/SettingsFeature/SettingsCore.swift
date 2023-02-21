// Created for weg-li in 2021.

import ApiClient
import ComposableArchitecture
import ContactFeature
import Foundation
import Helper
import KeychainClient
import SharedModels
import UIApplicationClient
import UIKit

public struct SettingsDomain: Reducer {
  public init() {}
  
  @Dependency(\.applicationClient) var applicationClient
  @Dependency(\.keychainClient) var keychainClient
  @Dependency(\.fileClient) var fileClient
  @Dependency(\.continuousClock) var clock
  
  // swiftlint:disable force_unwrapping
  static public let imprintLink = URL(string: "https://www.weg.li/imprint")!
  static public let gitHubProjectLink = URL(string: "https://github.com/weg-li/weg-li-ios")!
  static public let donateLink = URL(string: "https://www.weg.li/donate")!
  // swiftlint:enable force_unwrapping
  
  public struct State: Equatable {
    public init(
      accountSettingsState: AccountSettingsDomain.State,
      userSettings: UserSettings
    ) {
      self.accountSettingsState = accountSettingsState
      self.userSettings = userSettings
    }
    
    public var accountSettingsState: AccountSettingsDomain.State
    public var userSettings: UserSettings
    public var destination: Destination?
    
    public enum Destination: Equatable {
      case accountSettings
    }
  }
  
  public enum Action: Equatable {
    case accountSettings(AccountSettingsDomain.Action)
    case userSettings(UserSettingsDomain.Action)
    case openLicensesRowTapped
    case openImprintTapped
    case donateTapped
    case openGitHubProjectTapped
    case setDestination(State.Destination?)
  }
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.accountSettingsState, action: /Action.accountSettings) {
      AccountSettingsDomain()
    }
    
    Scope(state: \.userSettings, action: /Action.userSettings) {
      UserSettingsDomain()
    }
    
    Reduce<State, Action> { state, action in
      switch action {
      case .accountSettings:
        return .none
        
      case .openLicensesRowTapped:
        return .fireAndForget {
          guard
            let url = await URL(string: applicationClient.openSettingsURLString())
          else { return }
          _ = await applicationClient.open(url, [:])
        }
        
      case .openImprintTapped:
        return .fireAndForget {
          _ = await applicationClient.open(Self.imprintLink, [:])
        }
      case .openGitHubProjectTapped:
        return .fireAndForget {
          _ = await applicationClient.open(Self.gitHubProjectLink, [:])
        }
      case .donateTapped:
        return .fireAndForget {
          _ = await applicationClient.open(Self.donateLink, [:])
        }
      case .userSettings:
        let userSettings = state.userSettings
        return .fireAndForget {
          enum CancelID {}
          try await withTaskCancellation(id: CancelID.self, cancelInFlight: true) {
            try await clock.sleep(for: .seconds(0.3))
            try await fileClient.saveUserSettings(userSettings)
          }
        }
        
      case .setDestination(let value):
        state.destination = value
        return .none
      }
    }
  }
}
