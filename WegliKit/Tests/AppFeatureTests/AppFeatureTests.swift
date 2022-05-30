// Created for weg-li in 2021.

import AppFeature
import ApiClient
import ComposableArchitecture
import ComposableCoreLocation
import Combine
import ContactFeature
import FileClient
import ImagesFeature
import KeychainClient
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
        wegliService: .noop,
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
        wegliService: .noop,
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
        wegliService: .noop,
        date: fixedDate,
        uuid: fixedUUID
      )
    )
        
    let result = MFMailComposeResult.sent
    store.send(.report(.mail(.setMailResult(result)))) {
      var report = $0.reportDraft
      report.images.storedPhotos.removeAll()
      report.mail.mailComposeResult = result
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
    var state = AppState(reportDraft: report)
    state.settings.contact = .preview
    
    let store = TestStore(
      initialState: state,
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler(),
        backgroundQueue: scheduler.eraseToAnyScheduler(),
        fileClient: .noop,
        keychainClient: .noop,
        apiClient: .noop,
        wegliService: .noop,
        date: fixedDate,
        uuid: fixedUUID
      )
    )
    
    store.send(.report(.resetConfirmButtonTapped)) {
      $0.reportDraft = ReportState(
        uuid: self.fixedUUID,
        images: .init(),
        contactState: .init(
          contact: state.settings.contact.contact,
          alert: nil
        ),
        date: self.fixedDate
      )
    }
    store.receive(.report(.dismissAlert))
  }
  
  func test_ActionStoredApiTokenLoaded() {
    var state = AppState(reportDraft: report)
    state.settings.contact = .preview
    
    let token = "API Token"
    var keychainClient = KeychainClient.noop
    keychainClient.getString = { _ in
      return Just(token)
        .eraseToEffect()
    }
    
    var wegliService = WegliAPIService.noop
    wegliService.getNotices = {
      Just([.mock])
        .setFailureType(to: ApiError.self)
        .eraseToEffect()
    }
    
    let store = TestStore(
      initialState: state,
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: .immediate,
        backgroundQueue: scheduler.eraseToAnyScheduler(),
        fileClient: .noop,
        keychainClient: keychainClient,
        apiClient: .noop,
        wegliService: wegliService,
        date: fixedDate,
        uuid: fixedUUID
      )
    )
    
    store.send(.appDelegate(.didFinishLaunching))
    store.receive(.storedApiTokenLoaded(.success(token))) {
      $0.reportDraft.apiToken = token
      $0.settings.accountSettingsState.accountSettings.apiToken = token
    }
  }
  
  func test_ActionFetchNoticeResponse_shouldStoreNoticeToFileClient() {
    var state = AppState(reportDraft: report)
    state.settings.contact = .preview
    
    var didSaveNotices = false
    
    var fileClient = FileClient.noop
    fileClient.save = { _, _ in
      didSaveNotices = true
      return .none
    }
    
    let store = TestStore(
      initialState: state,
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: .immediate,
        backgroundQueue: scheduler.eraseToAnyScheduler(),
        fileClient: fileClient,
        keychainClient: .noop,
        apiClient: .noop,
        wegliService: .noop,
        date: fixedDate,
        uuid: fixedUUID
      )
    )
    
    store.send(.fetchNoticesResponse(.success([]))) {
      XCTAssertFalse($0.isFetchingNotices)
      $0.notices = .empty(.emptyNotices)
    }
    XCTAssertTrue(didSaveNotices)
  }
  
  func test_ActionOnAccountSettings_shouldPersistAccountsSettings() {
    var state = AppState(reportDraft: report)
    state.settings.contact = .preview
    
    let store = TestStore(
      initialState: state,
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: .immediate,
        backgroundQueue: scheduler.eraseToAnyScheduler(),
        fileClient: .noop,
        keychainClient: .noop,
        apiClient: .noop,
        wegliService: .noop,
        date: fixedDate,
        uuid: fixedUUID
      )
    )
    
    store.send(.settings(.accountSettings(.setApiToken("TOKEN")))) {
      $0.settings.accountSettingsState.accountSettings.apiToken = "TOKEN"
      $0.reportDraft.apiToken = "TOKEN"
    }
  }
  
  func test_Action_onAppear_shouldFetchNoticesWhenTokenisAdded() {
    var state = AppState(reportDraft: report)
    state.settings.accountSettingsState.accountSettings.apiToken = "TOKEN"
    
    var service = WegliAPIService.noop
    service.getNotices = {
      Just([.mock])
        .setFailureType(to: ApiError.self)
        .eraseToEffect()
    }
    
    let store = TestStore(
      initialState: state,
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        fileClient: .noop,
        keychainClient: .noop,
        apiClient: .noop,
        wegliService: service,
        date: fixedDate,
        uuid: fixedUUID
      )
    )
    
    store.send(.onAppear)
    store.receive(.fetchNotices) {
      XCTAssertTrue($0.isFetchingNotices)
    }
    store.receive(.fetchNoticesResponse(.success([.mock]))) {
      $0.notices = .results([.mock])
      XCTAssertFalse($0.isFetchingNotices)
    }
  }
  
  func test_Action_onAppear_shouldPresentNoTokenErrorState() {
    let store = TestStore(
      initialState: AppState(reportDraft: report),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: .immediate,
        backgroundQueue: .immediate,
        fileClient: .noop,
        keychainClient: .noop,
        apiClient: .noop,
        wegliService: .noop,
        date: fixedDate,
        uuid: fixedUUID
      )
    )
    
    store.send(.onAppear) {
      $0.notices = .error(
        .init(
          systemImageName: "key",
          title: "Kein API Token",
          body: "Füge deinen API Token in den Account Einstellungen hinzu um die App mit deinem weg.li Account zu verbinden"
        )
      )
    }
  }
}

extension AppState {
  init(reportDraft: ReportState) {
    self.init()
    self.reportDraft = reportDraft
  }
}
