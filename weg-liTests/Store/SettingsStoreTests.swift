// Created for weg-li in 2021.

import ComposableArchitecture
@testable import weg_li
import XCTest

class SettingsStoreTests: XCTestCase {
    var defaultEnvironment = SettingsEnvironment(
        uiApplicationClient: .init(
            open: { _, _ in .none },
            openSettingsURLString: { "" }
        )
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
            initialState: SettingsState(contact: .preview),
            reducer: settingsReducer,
            environment: env
        )

        store.assert(
            .send(.openLicensesRowTapped)
        )
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
            initialState: SettingsState(contact: .preview),
            reducer: settingsReducer,
            environment: env
        )

        store.assert(
            .send(.openImprintTapped)
        )
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
            initialState: SettingsState(contact: .preview),
            reducer: settingsReducer,
            environment: env
        )

        store.assert(
            .send(.openGitHubProjectTapped)
        )
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
            initialState: SettingsState(contact: .preview),
            reducer: settingsReducer,
            environment: env
        )

        store.assert(
            .send(.donateTapped)
        )
        XCTAssertEqual(openedUrl, env.donateLink)
    }
}
