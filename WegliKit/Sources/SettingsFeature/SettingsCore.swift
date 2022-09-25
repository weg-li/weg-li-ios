// Created for weg-li in 2021.

import ApiClient
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
  public var uiApplicationClient: UIApplicationClient
  public var keychainClient: KeychainClient
  public var mainQueue: AnySchedulerOf<DispatchQueue>
}

/// Reducer handling actions from the SettingsView and the descending EditDescriptionView.
public let settingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment>.combine(
  accountSettingsReducer.pullback(
    state: \.accountSettingsState,
    action: /SettingsAction.accountSettings,
    environment: { parent in
      AccountSettingsEnvironment(uiApplicationClient: parent.uiApplicationClient)
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
      return .fireAndForget {
        guard
          let url = await URL(string: env.uiApplicationClient.openSettingsURLString())
        else { return }
        _ = await env.uiApplicationClient.open(url, [:])
      }
      
    case .openImprintTapped:
      return .fireAndForget {
        _ = await env.uiApplicationClient.open(env.imprintLink, [:])
      }
    case .openGitHubProjectTapped:
      return .fireAndForget {
        _ = await env.uiApplicationClient.open(env.gitHubProjectLink, [:])
      }
    case .donateTapped:
      return .fireAndForget {
        _ = await env.uiApplicationClient.open(env.donateLink, [:])
      }
    case .contact, .userSettings:
      return .none
    }
  }
)
.onChange(of: \.accountSettingsState.accountSettings.apiToken) { key, _, _, environment in
  enum CancelID {}
  
  return .fireAndForget {
    await withTaskCancellation(id: CancelID.self, cancelInFlight: true) {
      try? await environment.mainQueue.sleep(for: .seconds(0.3))
      _ = await environment.keychainClient.setApiToken(key)
    }
  }
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
