// Created for weg-li in 2021.

import ComposableArchitecture
import MessageUI
import MailFeature
import XCTest

class MailStoreTests: XCTestCase {
  func test_presentMailViewAction_shouldUpdateState() {
    let store = TestStore(
      initialState: MailViewState(
        mailComposeResult: nil,
        mail: .init(),
        isPresentingMailContent: false
      ),
      reducer: mailViewReducer,
      environment: MailViewEnvironment()
    )
    
    store.send(.presentMailContentView(true)) {
      $0.isPresentingMailContent = true
    }
  }
  
  func test_setMailResult_shouldUpdateState() {
    let store = TestStore(
      initialState: MailViewState(
        mailComposeResult: nil,
        mail: .init(),
        isPresentingMailContent: false
      ),
      reducer: mailViewReducer,
      environment: MailViewEnvironment()
    )
    
    let result = MFMailComposeResult(rawValue: 2)!
    store.send(.setMailResult(result)) {
      $0.mailComposeResult = result
    }
  }
}
