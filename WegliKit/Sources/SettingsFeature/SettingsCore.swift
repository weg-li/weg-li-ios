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

public struct SettingsDomain: ReducerProtocol {
  public init() {}
  
  @Dependency(\.applicationClient) var applicationClient
  @Dependency(\.keychainClient) var keychainClient
  // swiftlint:disable force_unwrapping
  public let imprintLink = URL(string: "https://www.weg.li/imprint")!
  public let gitHubProjectLink = URL(string: "https://github.com/weg-li/weg-li-ios")!
  public let donateLink = URL(string: "https://www.weg.li/donate")!
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
  }
  
  public enum Action: Equatable {
    case accountSettings(AccountSettingsDomain.Action)
    case userSettings(UserSettingsDomain.Action)
    case openLicensesRowTapped
    case openImprintTapped
    case donateTapped
    case openGitHubProjectTapped
  }
  
  public var body: some ReducerProtocol<State, Action> {
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
          _ = await applicationClient.open(imprintLink, [:])
        }
      case .openGitHubProjectTapped:
        return .fireAndForget {
          _ = await applicationClient.open(gitHubProjectLink, [:])
        }
      case .donateTapped:
        return .fireAndForget {
          _ = await applicationClient.open(donateLink, [:])
        }
      case .userSettings:
        return .none
      }
    }
  }
}
