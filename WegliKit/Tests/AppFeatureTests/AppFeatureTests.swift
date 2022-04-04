// Created for weg-li in 2021.

import AppFeature
import ComposableArchitecture
import ComposableCoreLocation
import ContactFeature
import FileClient
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
      location: .init(userLocationState: .init()),
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
        backgroundQueue: scheduler.eraseToAnyScheduler(),
        fileClient: .noop
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
      $0.reportDraft.contactState.contact.firstName = newContact.contact.firstName
      $0.settings.contact.contact.firstName = newContact.contact.firstName
    }
  }
  
  func test_updateReport_ShouldUpdateState() {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler(),
        backgroundQueue: scheduler.eraseToAnyScheduler(),
        fileClient: .noop
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
    var didWriteReports = false
    var fileCient = FileClient.noop
    fileCient.save = { key, _ in
      didWriteReports = key == "reports"
      return .none
    }
    
    let store = TestStore(
      initialState: AppState(reportDraft: report),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler(),
        backgroundQueue: scheduler.eraseToAnyScheduler(),
        fileClient: fileCient
      )
    )
    
    store.send(.report(.mail(.setMailResult(MFMailComposeResult(rawValue: 2))))) {
      $0.reports = [self.report]
    }
    store.receive(.reportSaved) {
      $0.reportDraft = Report(
        images: .init(),
        contactState: .init(contact: .empty, alert: nil)
      )
    }
    XCTAssertTrue(didWriteReports)
  }
  
  func test_resetReportConfirmButtonTap_shouldResetDraftReport() {
    var AppState = AppState(reportDraft: report)
    AppState.settings.contact = .preview
    
    let store = TestStore(
      initialState: AppState,
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler(),
        backgroundQueue: scheduler.eraseToAnyScheduler(),
        fileClient: .noop
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
