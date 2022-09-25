// Created for weg-li in 2021.

import ComposableArchitecture
import SettingsFeature
import XCTest

@MainActor
final class SettingsStoreTests: XCTestCase {
  var defaultEnvironment = SettingsEnvironment(
    uiApplicationClient: .init(
      open: { _, _ in .none },
      openSettingsURLString: { "" }
    ),
    keychainClient: .noop,
    mainQueue: .immediate
  )
  
  func test_setOpenLicensesRow_shouldCallURL() {
    var openedUrl: URL!
    let settingsURL = "settings:weg-li//weg-li/settings"
    
    var env = defaultEnvironment
    env.uiApplicationClient.openSettingsURLString = { settingsURL }
    env.uiApplicationClient.open = { url, _ in
      openedUrl = url
      return .init(value: true)
    }
    
    let store = TestStore(
      initialState: SettingsState(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        contact: .preview,
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: settingsReducer,
      environment: env
    )
    
    store.send(.openLicensesRowTapped)
    XCTAssertEqual(openedUrl, URL(string: settingsURL))
  }
  
  func test_setOpenImprintRow_shouldCallURL() {
    var openedUrl: URL!
    
    var env = defaultEnvironment
    env.uiApplicationClient.open = { url, _ in
      openedUrl = url
      return .init(value: true)
    }
    
    let store = TestStore(
      initialState: SettingsState(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        contact: .preview,
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: settingsReducer,
      environment: env
    )
    
    store.send(.openImprintTapped)
    XCTAssertEqual(openedUrl, env.imprintLink)
  }
  
  func test_setOpenGitHubRow_shouldCallURL() {
    var openedUrl: URL!
    
    var env = defaultEnvironment
    env.uiApplicationClient.open = { url, _ in
      openedUrl = url
      return .init(value: true)
    }
    
    let store = TestStore(
      initialState: SettingsState(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        contact: .preview,
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: settingsReducer,
      environment: env
    )
    
    store.send(.openGitHubProjectTapped)
    XCTAssertEqual(openedUrl, env.gitHubProjectLink)
  }
  
  func test_donateTapped_shouldCallURL() {
    var openedUrl: URL!
    
    var env = defaultEnvironment
    env.uiApplicationClient.open = { url, _ in
      openedUrl = url
      return .init(value: true)
    }
    
    let store = TestStore(
      initialState: SettingsState(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        contact: .preview,
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: settingsReducer,
      environment: env
    )
    
    store.send(.donateTapped)
    XCTAssertEqual(openedUrl, env.donateLink)
  }
  
  func test_action_accountSettings_setApiToken_shouldPersistToken() {
    var env = defaultEnvironment
    
    var didWriteTokenToKeyChain = false
    env.keychainClient.setString = { _, _, _ in
      didWriteTokenToKeyChain = true
      return .none
    }
    
    let store = TestStore(
      initialState: SettingsState(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        contact: .preview,
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: settingsReducer,
      environment: env
    )
    
    store.send(.accountSettings(.setApiToken("TOKEN"))) {
      $0.accountSettingsState.accountSettings.apiToken = "TOKEN"
    }
    XCTAssertTrue(didWriteTokenToKeyChain)
  }
  
  func test_action_openUserSettings_shouldCallURL() {
    var openedUrl: URL!
    
    var env = defaultEnvironment
    env.uiApplicationClient.open = { url, _ in
      openedUrl = url
      return .init(value: true)
    }
    
    let store = TestStore(
      initialState: SettingsState(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        contact: .preview,
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: settingsReducer,
      environment: env
    )
    
    store.send(.accountSettings(.openUserSettings))
    XCTAssertEqual(openedUrl, URL(string: "https://www.weg.li/user")!)
  }
}
