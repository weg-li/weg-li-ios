// Created for weg-li in 2021.

import ApiClient
import AppFeature
import Combine
import ComposableArchitecture
import ComposableCoreLocation
import ContactFeature
import FileClient
import ImagesFeature
import KeychainClient
import MessageUI
import PathMonitorClient
import ReportFeature
import SharedModels
import XCTest

public extension UUID {
  static let reportId = Self(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!
}


@MainActor
final class AppStoreTests: XCTestCase {
  let fixedUUID = { UUID.reportId }
  let fixedDate = { Date(timeIntervalSinceReferenceDate: 0) }
  let scheduler = DispatchQueue.immediate.eraseToAnyScheduler()
  var userDefaults: UserDefaults!
  
  var report: ReportState!
  
  func defaultAppEnvironment(
    mainQueue: AnySchedulerOf<DispatchQueue> = .immediate,
    backgroundQueue: AnySchedulerOf<DispatchQueue> = .immediate,
    fileClient: FileClient = .noop,
    keychainClient: KeychainClient = .noop,
    apiClient: APIClient = .noop,
    wegliService: WegliAPIService = .noop,
    pathMonitorClient: PathMonitorClient = .satisfied,
    date: @escaping () -> Date = { Date(timeIntervalSinceReferenceDate: 0) },
    uuid: @escaping () -> UUID = { UUID.reportId }
  ) -> AppEnvironment {
    AppEnvironment(
      mainQueue: mainQueue,
      backgroundQueue: backgroundQueue,
      fileClient: fileClient,
      keychainClient: keychainClient,
      apiClient: apiClient,
      wegliService: wegliService,
      pathMonitorClient: pathMonitorClient,
      date: date,
      uuid: uuid
    )
  }
  
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
  
  func test_updateContact_ShouldUpdateState() async {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: defaultAppEnvironment()
    )
    
    let newContact: ContactState = .preview
    
    await store.send(
      .report(
        .contact(
          .contact(.set(\.$firstName, newContact.contact.firstName))
        )
      )
    ) {
      $0.reportDraft.contactState.contact.firstName = newContact.contact.firstName
      $0.contact.firstName = newContact.contact.firstName
    }
  }
    
  func test_resetReportConfirmButtonTap_shouldResetDraftReport() {
    let state = AppState(reportDraft: report)
    
    let store = TestStore(
      initialState: state,
      reducer: appReducer,
      environment: defaultAppEnvironment()
    )
    
    store.send(.report(.onResetConfirmButtonTapped)) {
      $0.reportDraft = ReportState(
        uuid: self.fixedUUID,
        images: .init(),
        contactState: .init(
          contact: .empty,
          alert: nil
        ),
        date: self.fixedDate
      )
    }
    store.receive(.report(.dismissAlert))
  }
  
  func test_ActionStoredApiTokenLoaded() async {
    let mainQueue = DispatchQueue.test
    
    let state = AppState(reportDraft: report)
    
    let token = "API Token"
    var keychainClient = KeychainClient.noop
    keychainClient.getString = { _ in token }
    
    var wegliService = WegliAPIService.noop
    wegliService.getNotices = { _ in [.mock]}
    
    let store = TestStore(
      initialState: state,
      reducer: appReducer,
      environment: defaultAppEnvironment(
        mainQueue: mainQueue.eraseToAnyScheduler(),
        keychainClient: keychainClient,
        wegliService: wegliService
      )
    )
    store.environment.fileClient.load = { @Sendable [user = state.settings.userSettings] key in
      if key == "contact-settings" {
        return try! Contact.preview.encoded()
      }
      if key == "user-settings" {
        return try! user.encoded()
      }
      fatalError()
    }
    
    await store.send(.appDelegate(.didFinishLaunching))
    await mainQueue.advance(by: 0.5)
    await store.receive(.contactSettingsLoaded(.success(.preview))) {
      $0.contact = .preview
      $0.reportDraft.contactState.contact = .preview
    }
    await store.receive(.userSettingsLoaded(.success(state.settings.userSettings)))
    await store.receive(.storedApiTokenLoaded(.success(token))) {
      $0.reportDraft.apiToken = token
      $0.settings.accountSettingsState.accountSettings.apiToken = token
    }
    await store.finish()
  }
  
  func test_ActionFetchNoticeResponse_shouldNotStoreNoticeToFileClientWhenResponseIsEmpty() async {
    let state = AppState(reportDraft: report)
    let mainQueue = DispatchQueue.test
    
    let didSaveNotices = ActorIsolated(false)
    
    var fileClient = FileClient.noop
    fileClient.save = { @Sendable _, _ in
      await didSaveNotices.setValue(true)
      return ()
    }
    
    let store = TestStore(
      initialState: state,
      reducer: appReducer,
      environment: defaultAppEnvironment(
        mainQueue: mainQueue.eraseToAnyScheduler(),
        fileClient: fileClient
      )
    )
    
    await store.send(.fetchNoticesResponse(.success([]))) {
      $0.notices = .empty(.emptyNotices())
    }
    await didSaveNotices.withValue { value in
      XCTAssertFalse(value)
    }
  }
  
  func test_ActionFetchNoticeResponse_shouldStoreNoticeToFileClient() async {
    let state = AppState(reportDraft: report)
    
    let didSaveNotices = ActorIsolated(false)
    
    var fileClient = FileClient.noop
    fileClient.save = { @Sendable _, _ in
      await didSaveNotices.setValue(true)
      return ()
    }
    
    let store = TestStore(
      initialState: state,
      reducer: appReducer,
      environment: defaultAppEnvironment(
        fileClient: fileClient
      )
    )
    store.environment.wegliService.getNotices = { _ in .placeholder }
    
    await store.send(.fetchNoticesResponse(.success(.placeholder))) {
      $0.notices = .results(.placeholder)
    }
    await didSaveNotices.withValue { value in
      XCTAssertTrue(value)
    }
  }
  
  func test_ActionOnAccountSettings_shouldPersistAccountsSettings() async {
    let state = AppState(reportDraft: report)
    
    let store = TestStore(
      initialState: state,
      reducer: appReducer,
      environment: defaultAppEnvironment()
    )
    
    await store.send(.settings(.accountSettings(.setApiToken("TOKEN")))) {
      $0.settings.accountSettingsState.accountSettings.apiToken = "TOKEN"
      $0.reportDraft.apiToken = "TOKEN"
    }
  }
  
  func test_Action_onAppear_shouldFetchNoticesWhenTokenisAdded() async {
    var state = AppState(reportDraft: report)
    state.settings.accountSettingsState.accountSettings.apiToken = "TOKEN"
    
    var service = WegliAPIService.noop
    service.getNotices = { _ in [.mock] }
    
    let store = TestStore(
      initialState: state,
      reducer: appReducer,
      environment: defaultAppEnvironment(wegliService: service)
    )
    store.environment.fileClient.load = { @Sendable key in
      if key == "contact-settings" {
        return try! Contact.preview.encoded()
      }
      fatalError()
    }
    
    await store.send(.onAppear)
    await store.receive(.fetchNotices(forceReload: false))
    await store.receive(.fetchNoticesResponse(.success([.mock]))) {
      $0.notices = .results([.mock])
    }
  }
  
  func test_Action_onAppear_shouldPresentNoTokenErrorState() {
    let store = TestStore(
      initialState: AppState(reportDraft: report),
      reducer: appReducer,
      environment: defaultAppEnvironment()
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
  
  func test_Action_fetchNotices_shouldNotReload_whenElementsHaveBeenLoaded_andNoForceReload() {
    var state = AppState(reportDraft: report)
    state.notices = .results([.mock])
    
    let store = TestStore(
      initialState: state,
      reducer: appReducer,
      environment: defaultAppEnvironment()
    )
    
    store.send(.fetchNotices(forceReload: false))
    // does not fetch notices again
  }
  
  func test_Action_fetchNotices_shouldReload_whenElementsHaveBeenLoaded_andForceReload() async {
    var state = AppState(reportDraft: report)
    state.notices = .results([.placeholder])
    
    var service = WegliAPIService.noop
    service.getNotices = { _ in [.mock] }
    
    let store = TestStore(
      initialState: state,
      reducer: appReducer,
      environment: defaultAppEnvironment(wegliService: service)
    )
    
    await store.send(.fetchNotices(forceReload: true)) {
      $0.notices = .loading
    }
    await store.receive(.fetchNoticesResponse(.success([.mock]))) {
      $0.notices = .results([.mock])
    }
  }
}

extension AppState {
  init(reportDraft: ReportState) {
    self.init()
    self.reportDraft = reportDraft
  }
}
