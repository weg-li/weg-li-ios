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
    
    @PresentationState var destination: Destination.State?
  }
  
  @CasePathable
  public enum Action: Equatable {
    case userSettings(UserSettingsDomain.Action)
    case openLicensesRowTapped
    case openImprintTapped
    case donateTapped
    case openGitHubProjectTapped
    case accountSettingsButtonTapped
    case destination(PresentationAction<Destination.Action>)
  }
  
  @Reducer
  public struct Destination {
    public enum State: Equatable {
      case accountSettings(AccountSettingsDomain.State)
    }

    public enum Action: Equatable, Sendable {
      case accountSettings(AccountSettingsDomain.Action)
    }

    public var body: some ReducerOf<Self> {
      Scope(state: \.accountSettings, action: \.accountSettings) {
        AccountSettingsDomain()
      }
    }
  }
  
  enum CancelID { case debounce }
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.userSettings, action: /Action.userSettings) {
      UserSettingsDomain()
    }
    
    Reduce<State, Action> { state, action in
      switch action {
      case .accountSettingsButtonTapped:
        state.destination = .accountSettings(AccountSettingsDomain.State(accountSettings: AccountSettings(apiToken: "")))
        return .none
      
      case .openLicensesRowTapped:
        return .run { send in
          guard
            let url = await URL(string: applicationClient.openSettingsURLString())
          else { return }
          _ = await applicationClient.open(url, [:])
        }
        
      case .openImprintTapped:
        return .run { _ in
          _ = await applicationClient.open(Self.imprintLink, [:])
        }
      case .openGitHubProjectTapped:
        return .run { _ in
          _ = await applicationClient.open(Self.gitHubProjectLink, [:])
        }
      case .donateTapped:
        return .run { _ in
          _ = await applicationClient.open(Self.donateLink, [:])
        }
      case .userSettings:
        let userSettings = state.userSettings
        return .run { _ in
          try await withTaskCancellation(id: CancelID.debounce, cancelInFlight: true) {
            try await clock.sleep(for: .seconds(0.3))
            try await fileClient.saveUserSettings(userSettings)
          }
        }
        
      case .destination:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination) {
      Destination()
    }
  }
}
