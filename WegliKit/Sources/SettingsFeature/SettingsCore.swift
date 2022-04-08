// Created for weg-li in 2021.

import ComposableArchitecture
import ContactFeature
import Foundation
import SharedModels
import UIApplicationClient
import UIKit

public struct SettingsState: Equatable {
  public init(contact: ContactState) {
    self.contact = contact
  }
  
  public var contact: ContactState
}

public enum SettingsAction: Equatable {
  case contact(ContactStateAction)
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
    case .contact:
      return .none
    }
  }
)
