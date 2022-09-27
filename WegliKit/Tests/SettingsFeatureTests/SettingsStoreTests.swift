// Created for weg-li in 2021.

import ComposableArchitecture
import SettingsFeature
import XCTest

@MainActor
final class SettingsStoreTests: XCTestCase {
  var defaultEnvironment = SettingsEnvironment(
    uiApplicationClient: .init(
      open: { _, _ in false },
      openSettingsURLString: { "" }
    ),
    keychainClient: .noop,
    mainQueue: .immediate
  )
  
  func test_setOpenLicensesRow_shouldCallURL() async {
    let openedUrl = ActorIsolated<URL?>(nil)
    let settingsURL = "settings:weg-li//weg-li/settings"
    
    var env = defaultEnvironment
    env.uiApplicationClient.openSettingsURLString = { settingsURL }
    env.uiApplicationClient.open = { @Sendable url, _ in
      await openedUrl.setValue(url)
      return true
    }
    
    let store = TestStore(
      initialState: SettingsState(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: settingsReducer,
      environment: env
    )
    
    await store.send(.openLicensesRowTapped)
    await openedUrl.withValue({ url in
      XCTAssertEqual(url, URL(string: settingsURL))
    })
  }
  
  func test_setOpenImprintRow_shouldCallURL() async {
    let openedUrl = ActorIsolated<URL?>(nil)
    
    var env = defaultEnvironment
    env.uiApplicationClient.open = { @Sendable url, _ in
      await openedUrl.setValue(url)
      return .init(true)
    }
    
    let store = TestStore(
      initialState: SettingsState(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: settingsReducer,
      environment: env
    )
    
    await store.send(.openImprintTapped)
    await openedUrl.withValue({ [link = env.imprintLink] url in
      XCTAssertEqual(url, link)
    })
  }
  
  func test_setOpenGitHubRow_shouldCallURL() async {
    let openedUrl = ActorIsolated<URL?>(nil)
    
    var env = defaultEnvironment
    env.uiApplicationClient.open = { @Sendable url, _ in
      await openedUrl.setValue(url)
      return .init(true)
    }
    
    let store = TestStore(
      initialState: SettingsState(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: settingsReducer,
      environment: env
    )
    
    await store.send(.openGitHubProjectTapped)
    await openedUrl.withValue({ [link = env.gitHubProjectLink] url in
      XCTAssertEqual(url, link)
    })
  }
  
  func test_donateTapped_shouldCallURL() async {
    let openedUrl = ActorIsolated<URL?>(nil)
    
    var env = defaultEnvironment
    env.uiApplicationClient.open = { @Sendable url, _ in
      await openedUrl.setValue(url)
      return .init(true)
    }
    
    let store = TestStore(
      initialState: SettingsState(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: settingsReducer,
      environment: env
    )
    
    await store.send(.donateTapped)
    await openedUrl.withValue({ [link = env.donateLink] url in
      XCTAssertEqual(url, link)
    })
  }
  
  func test_action_accountSettings_setApiToken_shouldPersistToken() async {
    var env = defaultEnvironment
    
    let didWriteTokenToKeyChain = ActorIsolated<Bool>(false)
    env.keychainClient.setString = { @Sendable [self] _, _, _ in
      await didWriteTokenToKeyChain.setValue(true)
      return true
    }
    
    let store = TestStore(
      initialState: SettingsState(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: settingsReducer,
      environment: env
    )
    
    await store.send(.accountSettings(.setApiToken("TOKEN"))) {
      $0.accountSettingsState.accountSettings.apiToken = "TOKEN"
    }
    await didWriteTokenToKeyChain.withValue({ didWriteToKeychain in
      XCTAssertTrue(didWriteToKeychain)
    })
  }
  
  func test_action_openUserSettings_shouldCallURL() async {
    let openedUrl = ActorIsolated<URL?>(nil)
    
    var env = defaultEnvironment
    env.uiApplicationClient.open = { @Sendable url, _ in
      await openedUrl.setValue(url)
      return .init(true)
    }
    
    let store = TestStore(
      initialState: SettingsState(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: settingsReducer,
      environment: env
    )
    
    await store.send(.accountSettings(.openUserSettings))
    await openedUrl.withValue({ url in
      XCTAssertEqual(url, URL(string: "https://www.weg.li/user")!)
    })
  }
}
