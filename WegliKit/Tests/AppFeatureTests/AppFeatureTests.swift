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

extension UUID {
  public static let ReportId = Self(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!
}


class AppStoreTests: XCTestCase {
  let fixedUUID = { UUID.ReportId }
  let fixedDate = { Date(timeIntervalSinceReferenceDate: 0) }
  let scheduler = DispatchQueue.immediate.eraseToAnyScheduler()
  var userDefaults: UserDefaults!
  
  var report: ReportState!
  
  override func setUp() {
    super.setUp()
    
    report = ReportState(
      uuid: fixedUUID,
      images: ImagesViewState(
        showImagePicker: false,
        storedPhotos: [PickerImageResult(uiImage: UIImage(systemName: "pencil")!)!],
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
        backgroundQueue: scheduler.eraseToAnyScheduler(),
        fileClient: .noop,
        keychainClient: .noop,
        apiClient: .noop,
        noticesService: .noop,
        date: fixedDate,
        uuid: fixedUUID
      )
    )
    
    let newContact: ContactState = .preview
    
    store.send(
      .settings(
        .contact(
          .contact(.set(\.$firstName, newContact.contact.firstName))
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
        fileClient: .noop,
        keychainClient: .noop,
        apiClient: .noop,
        noticesService: .noop,
        date: fixedDate,
        uuid: fixedUUID
      )
    )
    
    let newContact: ContactState = .preview
    
    store.send(
      .report(
        .contact(
          .contact(.set(\.$firstName, newContact.contact.firstName))
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
      didWriteReports = true
      return .none
    }
    
    let store = TestStore(
      initialState: AppState(reportDraft: report),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        fileClient: fileCient,
        keychainClient: .noop,
        apiClient: .noop,
        noticesService: .noop,
        date: fixedDate,
        uuid: fixedUUID
      )
    )
        
    let result = MFMailComposeResult.sent
    store.send(.report(.mail(.setMailResult(result)))) {
      var report = $0.reportDraft
      report.images.storedPhotos.removeAll()
      report.mail.mailComposeResult = result
      
      $0.reports = [report]
      $0.reportDraft = report
      $0.reportDraft.mail.mailComposeResult = result
    }
    store.receive(.reportSaved) {
      $0.reportDraft = ReportState(
        uuid: self.fixedUUID,
        images: .init(),
        contactState: .init(contact: .empty, alert: nil),
        date: self.fixedDate
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
        fileClient: .noop,
        keychainClient: .noop,
        apiClient: .noop,
        noticesService: .noop,
        date: fixedDate,
        uuid: fixedUUID
      )
    )
    
    store.send(.report(.resetConfirmButtonTapped)) {
      $0.reportDraft = ReportState(
        uuid: self.fixedUUID,
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
  init(reportDraft: ReportState) {
    self.init()
    self.reportDraft = reportDraft
  }
}
