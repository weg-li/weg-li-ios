// Created for weg-li in 2021.

import AppFeature
import ComposableArchitecture
import ComposableCoreLocation
import ContactFeature
import ImagesFeature
import MessageUI
import ReportFeature
import SharedModels
import XCTest

class AppStoreTests: XCTestCase {
  let fixedUUID = { UUID() }
  let fixedDate = { Date() }
  let scheduler = DispatchQueue.immediate.eraseToAnyScheduler()
  var userDefaults: UserDefaults!
  
  var report: Report!
  
  override func setUp() {
    super.setUp()
    
    report = Report(
      uuid: fixedUUID(),
      images: ImagesViewState(
        showImagePicker: false,
        storedPhotos: [StorableImage(uiImage: UIImage(systemName: "pencil")!)!],
        coordinateFromImagePicker: .zero
      ),
      contactState: .preview,
      district: nil,
      date: fixedDate,
      description: .init(),
      location: .init(),
      mail: .init()
    )
    userDefaults = UserDefaults(suiteName: #file)
    userDefaults.removePersistentDomain(forName: #file)
  }
  
  func test_updateContact_ShouldUpdateState() {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler(),
        userDefaultsClient: .noop
      )
    )
    
    let newContact: ContactState = .preview
    
    store.send(
      .settings(
        .contact(
          .firstNameChanged(newContact.contact.firstName)
        )
      )
    ) {
      $0.settings.contact.contact.firstName = newContact.contact.firstName
    }
  }
  
  func test_updateReport_ShouldUpdateState() {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler(),
        userDefaultsClient: .noop
      )
    )
    
    let newContact: ContactState = .preview
    
    store.send(
      .report(
        .contact(
          .firstNameChanged(newContact.contact.firstName)
        )
      )
    ) {
      $0.settings.contact.contact.firstName = newContact.contact.firstName
      $0.reportDraft.contactState.contact.firstName = newContact.contact.firstName
    }
  }
  
  func test_sentMailResult_shouldAppendDraftReportToReports() {
    let store = TestStore(
      initialState: AppState(reportDraft: report),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler(),
        userDefaultsClient: .noop
      )
    )
    
//    store.send(
//      .report(
//        .mail(
//          .setMailResult(MFMailComposeResult(rawValue: 2)
//                        )
//        )
//      )
//    ) {
//      $0.reports = [self.report]
//    }
//    store.receive(.reportSaved) {
//      $0.reportDraft = Report(
//        images: .init(),
//        contactState: .init(contact: .empty, alert: nil)
//      )
//    }
  }
  
  func test_contactStateShouldBeSaved_onContactViewDisappearAction() {
    let store = TestStore(
      initialState: AppState(reportDraft: report),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler(),
        userDefaultsClient: .live(userDefaults: userDefaults)
      )
    )
    
    store.send(
      .settings(
        .contact(
          .firstNameChanged("Bob")
        )
      )
    ) {
      $0.settings.contact.contact.firstName = "Bob"
    }
    store.send(.settings(.contact(.onDisappear))) {
      $0.reportDraft.contactState = $0.settings.contact
      // check if contact has been saved to defaults
      XCTAssertEqual(
        store.environment.userDefaultsClient.contact,
        $0.settings.contact.contact
      )
    }
  }
  
  func test_resetReportConfirmButtonTap_shouldResetDraftReport() {
    var AppState = AppState(reportDraft: report)
    AppState.settings.contact = .preview
    
    let store = TestStore(
      initialState: AppState,
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler(),
        userDefaultsClient: .live(userDefaults: userDefaults)
      )
    )
    
    store.send(.report(.resetConfirmButtonTapped)) {
      $0.reportDraft = Report(
        images: .init(),
        contactState: .init(
          contact: AppState.settings.contact.contact,
          alert: nil
        ),
        date: self.fixedDate
      )
    }
    store.receive(.report(.dismissAlert))
  }
}

extension AppState {
  init(reportDraft: Report) {
    self.init()
    self.reportDraft = reportDraft
  }
}
