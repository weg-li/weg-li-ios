// Created for weg-li in 2021.

import ComposableArchitecture
import MessageUI
@testable import weg_li
import XCTest

class MailStoreTests: XCTestCase {
    func test_presentMailViewAction_shouldUpdateState() {
        let store = TestStore(
            initialState: MailViewState(
                mailComposeResult: nil,
                mail: .init(),
                isPresentingMailContent: false,
                district: .init()
            ),
            reducer: mailViewReducer,
            environment: MailViewEnvironment()
        )

        store.assert(
            .send(.presentMailContentView(true)) {
                $0.isPresentingMailContent = true
            }
        )
    }

    func test_setMailResult_shouldUpdateState() {
        let store = TestStore(
            initialState: MailViewState(
                mailComposeResult: nil,
                mail: .init(),
                isPresentingMailContent: false,
                district: .init()
            ),
            reducer: mailViewReducer,
            environment: MailViewEnvironment()
        )

        let result = MFMailComposeResult(rawValue: 2)!
        store.assert(
            .send(.setMailResult(result)) {
                $0.mailComposeResult = result
            }
        )
    }
}
