// Created for weg-li in 2021.

import ComposableArchitecture
import ContactFeature
import Foundation
import SharedModels
import UIApplicationClient
import UIKit

public struct SettingsState: Equatable {
  public init(
    contact: ContactState,
    userSettings: UserSettings
  ) {
    self.contact = contact
    self.userSettings = userSettings
  }
  
  public var contact: ContactState
  public var userSettings: UserSettings
}

public enum SettingsAction: Equatable {
  case contact(ContactStateAction)
  case userSettings(UserSettingsAction)
  case openLicensesRowTapped
  case openImprintTapped
  case donateTapped
  case openGitHubProjectTapped
}

public struct SettingsEnvironment {
  public init(uiApplicationClient: UIApplicationClient) {
    self.uiApplicationClient = uiApplicationClient
  }
  
  // swiftlint:disable force_unwrapping
  public let imprintLink = URL(string: "https://www.weg.li/imprint")!
  public let gitHubProjectLink = URL(string: "https://github.com/weg-li/weg-li-ios")!
  public let donateLink = URL(string: "https://www.weg.li/donate")!
  // swiftlint:enable force_unwrapping
  public var uiApplicationClient: UIApplicationClient
}

/// Reducer handling actions from the SettingsView and the descending EditDescriptionView.
public let settingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment>.combine(
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
