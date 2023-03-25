// Created for weg-li in 2021.

import ComposableArchitecture
import MailFeature
import MessageUI
import XCTest

@MainActor
final class MailStoreTests: XCTestCase {
  func test_presentMailViewAction_shouldUpdateState() async {
    let store = TestStore(
      initialState: MailDomain.State(
        mailComposeResult: nil,
        mail: .init(),
        isPresentingMailContent: false
      ),
      reducer: MailDomain()
    )
    
    await store.send(.presentMailContentView(true)) {
      $0.isPresentingMailContent = true
    }
  }
  
  func test_setMailResult_shouldUpdateState() async {
    let store = TestStore(
      initialState: MailDomain.State(
        mailComposeResult: nil,
        mail: .init(),
        isPresentingMailContent: false
      ),
      reducer: MailDomain()
    )
    
    let result = MFMailComposeResult(rawValue: 2)!
    await store.send(.setMailResult(result)) {
      $0.mailComposeResult = result
    }
  }
}
