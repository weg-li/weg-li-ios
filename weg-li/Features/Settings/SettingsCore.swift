// Created for weg-li in 2021.

import ComposableArchitecture
import Foundation
import UIKit

struct SettingsState: Equatable {
    var contact: ContactState
}

enum SettingsAction: Equatable {
    case contact(ContactAction)
    case openLicensesRowTapped
    case openImprintTapped
    case openGitHubProjectTapped
}

struct SettingsEnvironment {
    let imprintLink = URL(string: "https://www.weg.li/imprint")!
    let gitHubProjectLink = URL(string: "https://github.com/weg-li/weg-li-ios")!
    var uiApplicationClient: UIApplicationClient
}

let settingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment>.combine(
    contactReducer.pullback(
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
        case .contact:
            return .none
        }
    }
)
