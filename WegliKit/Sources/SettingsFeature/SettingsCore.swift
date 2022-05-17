// Created for weg-li in 2021.

import ComposableArchitecture
import ContactFeature
import Foundation
import KeychainClient
import SharedModels
import UIApplicationClient
import UIKit

public struct SettingsState: Equatable {
  public init(
    accountSettingsState: AccountSettingsState,
    contact: ContactState,
    userSettings: UserSettings
  ) {
    self.accountSettingsState = accountSettingsState
    self.contact = contact
    self.userSettings = userSettings
  }
  
  public var accountSettingsState: AccountSettingsState
  public var contact: ContactState
  public var userSettings: UserSettings
}

public enum SettingsAction: Equatable {
  case accountSettings(AccountSettingsAction)
  case contact(ContactStateAction)
  case userSettings(UserSettingsAction)
  case openLicensesRowTapped
  case openImprintTapped
  case donateTapped
  case openGitHubProjectTapped
}

public struct SettingsEnvironment {
  public init(
    uiApplicationClient: UIApplicationClient,
    keychainClient: KeychainClient,
    mainQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.uiApplicationClient = uiApplicationClient
    self.keychainClient = keychainClient
    self.mainQueue = mainQueue
  }
  
  // swiftlint:disable force_unwrapping
  public let imprintLink = URL(string: "https://www.weg.li/imprint")!
  public let gitHubProjectLink = URL(string: "https://github.com/weg-li/weg-li-ios")!
  public let donateLink = URL(string: "https://www.weg.li/donate")!
  // swiftlint:enable force_unwrapping
  public let uiApplicationClient: UIApplicationClient
  public let keychainClient: KeychainClient
  public let mainQueue: AnySchedulerOf<DispatchQueue>
}

/// Reducer handling actions from the SettingsView and the descending EditDescriptionView.
public let settingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment>.combine(
  accountSettingsReducer.pullback(
    state: \.accountSettingsState,
    action: /SettingsAction.accountSettings,
    environment: { parent in
      AccountSettingsEnvironment(
        uiApplicationClient: parent.uiApplicationClient
      )
    }
  ),
  contactViewReducer.pullback(
    state: \.contact,
    action: /SettingsAction.contact,
    environment: { _ in ContactEnvironment() }
  ),
  userSettingsReducer.pullback(
    state: \.userSettings,
    action: /SettingsAction.userSettings,
    environment: { _ in UserSettingsEnvironment() }
  ),
  Reducer { _, action, env in
    switch action {
    case .accountSettings:
      return .none
      
    case .openLicensesRowTapped:
      return URL(string: env.uiApplicationClient.openSettingsURLString())
        .map {
          env.uiApplicationClient.open($0, [:])
            .fireAndForget()
        }
      ?? .none
    case .openImprintTapped:
      return env.uiApplicationClient.open(env.imprintLink, [:])
        .fireAndForget()
    case .openGitHubProjectTapped:
      return env.uiApplicationClient.open(env.gitHubProjectLink, [:])
        .fireAndForget()
    case .donateTapped:
      return env.uiApplicationClient.open(env.donateLink, [:])
        .fireAndForget()
    case .contact, .userSettings:
      return .none
    }
  }
)
  .onChange(of: \.accountSettingsState.accountSettings.apiKey) { key, state, _, environment in
    struct SaveDebounceId: Hashable {}
    
    return environment.keychainClient
      .setApiToken(key)
      .fireAndForget()
      .debounce(id: SaveDebounceId(), for: .seconds(1), scheduler: environment.mainQueue)
  }


public enum UserSettingsAction: Equatable {
  case setShowsAllTextRecognitionResults(Bool)
}

public struct UserSettingsEnvironment {}

public let userSettingsReducer = Reducer<UserSettings, UserSettingsAction, UserSettingsEnvironment> { state, action, _ in
  switch action {
  case let .setShowsAllTextRecognitionResults(value):
    state.showsAllTextRecognitionSettings = value
    return .none
  }
}
