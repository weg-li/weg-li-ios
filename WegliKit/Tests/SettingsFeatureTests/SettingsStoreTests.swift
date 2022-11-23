// Created for weg-li in 2021.

import ComposableArchitecture
import SettingsFeature
import XCTest

@MainActor
final class SettingsStoreTests: XCTestCase {
  func test_setOpenLicensesRow_shouldCallURL() async {
    let openedUrl = ActorIsolated<URL?>(nil)
    let settingsURL = "settings:weg-li//weg-li/settings"
    
    
    let store = TestStore(
      initialState: SettingsDomain.State(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: SettingsDomain()
    )
    store.dependencies.applicationClient.openSettingsURLString = { settingsURL }
    store.dependencies.applicationClient.open = { @Sendable url, _ in
      await openedUrl.setValue(url)
      return true
    }
    
    await store.send(.openLicensesRowTapped)
    await openedUrl.withValue({ url in
      XCTAssertEqual(url, URL(string: settingsURL))
    })
  }
  
  func test_setOpenImprintRow_shouldCallURL() async {
    let openedUrl = ActorIsolated<URL?>(nil)
    
    let store = TestStore(
      initialState: SettingsDomain.State(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: SettingsDomain()
    )
    store.dependencies.applicationClient.open = { @Sendable url, _ in
      await openedUrl.setValue(url)
      return .init(true)
    }
    
    await store.send(.openImprintTapped)
    await openedUrl.withValue({ [link = SettingsDomain.imprintLink] url in
      XCTAssertEqual(url, link)
    })
  }
  
  func test_setOpenGitHubRow_shouldCallURL() async {
    let openedUrl = ActorIsolated<URL?>(nil)
    
    let store = TestStore(
      initialState: SettingsDomain.State(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: SettingsDomain()
    )
    store.dependencies.applicationClient.open = { @Sendable url, _ in
      await openedUrl.setValue(url)
      return .init(true)
    }
    
    await store.send(.openGitHubProjectTapped)
    await openedUrl.withValue({ [link = SettingsDomain.gitHubProjectLink] url in
      XCTAssertEqual(url, link)
    })
  }
  
  func test_donateTapped_shouldCallURL() async {
    let openedUrl = ActorIsolated<URL?>(nil)
    
    let store = TestStore(
      initialState: SettingsDomain.State(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: SettingsDomain()
    )
    store.dependencies.applicationClient.open = { @Sendable url, _ in
      await openedUrl.setValue(url)
      return .init(true)
    }
    
    await store.send(.donateTapped)
    await openedUrl.withValue({ [link = SettingsDomain.donateLink] url in
      XCTAssertEqual(url, link)
    })
  }
  
  func test_action_accountSettings_setApiToken_shouldPersistToken() async {
    let didWriteTokenToKeyChain = ActorIsolated<Bool>(false)
    
    let store = TestStore(
      initialState: SettingsDomain.State(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: SettingsDomain()
    )
    store.dependencies.keychainClient.setString = { @Sendable _, _, _ in
      await didWriteTokenToKeyChain.setValue(true)
      return true
    }
    store.dependencies.continuousClock = ImmediateClock()
    
    await store.send(.accountSettings(.setApiToken("TOKEN"))) {
      $0.accountSettingsState.accountSettings.apiToken = "TOKEN"
    }
    await didWriteTokenToKeyChain.withValue({ didWriteToKeychain in
      XCTAssertTrue(didWriteToKeychain)
    })
  }
  
  func test_action_openUserSettings_shouldCallURL() async {
    let openedUrl = ActorIsolated<URL?>(nil)
    
    let store = TestStore(
      initialState: SettingsDomain.State(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        userSettings: .init(showsAllTextRecognitionSettings: false)
      ),
      reducer: SettingsDomain()
    )
    store.dependencies.applicationClient.open = { @Sendable url, _ in
      await openedUrl.setValue(url)
      return .init(true)
    }
    
    await store.send(.accountSettings(.openUserSettings))
    await openedUrl.withValue({ url in
      XCTAssertEqual(url, URL(string: "https://www.weg.li/user")!)
    })
  }
}
