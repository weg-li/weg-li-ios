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
  
  var report: ReportDomain.State!
  
  override func setUp() {
    super.setUp()
    
    report = ReportDomain.State(
      uuid: fixedUUID,
      images: ImagesViewDomain.State(
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
      initialState: AppDomain.State(),
      reducer: AppDomain()
    )
    store.dependencies.fileClient = .noop
    store.dependencies.suspendingClock = ImmediateClock()
    
    let newContact: ContactDomain.State = .preview
    
    await store.send(
      .report(
        .contact(
          .contact(.set(\.$firstName, newContact.firstName))
        )
      )
    ) {
      $0.reportDraft.contactState.contact.firstName = newContact.firstName
      $0.contact.firstName = newContact.firstName
    }
  }
    
  func test_resetReportConfirmButtonTap_shouldResetDraftReport() {
    let store = TestStore(
      initialState: AppDomain.State(reportDraft: report),
      reducer: AppDomain()
    )
    store.dependencies.uuid = .constant(.reportId)
    store.dependencies.date = .constant(fixedDate())
    
    store.send(.report(.onResetConfirmButtonTapped)) {
      $0.reportDraft = ReportDomain.State(
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
    let clock = TestClock()
    
    let state = AppDomain.State(reportDraft: report)
    
    let token = "API Token"
    var keychainClient = KeychainClient.noop
    keychainClient.getString = { _ in token }
    
    var wegliService = WegliAPIService.noop
    wegliService.getNotices = { _ in [.mock]}
    
    let store = TestStore(
      initialState: state,
      reducer: AppDomain(),
      prepareDependencies: { dependencies in
        dependencies.keychainClient = keychainClient
        dependencies.apiService = wegliService
        dependencies.suspendingClock = clock
      }
    )
    store.dependencies.fileClient.load = { @Sendable [user = state.settings.userSettings] key in
      if key == "contact-settings" {
        return try! Contact.preview.encoded()
      }
      if key == "user-settings" {
        return try! user.encoded()
      }
      fatalError()
    }
    
    await store.send(.appDelegate(.didFinishLaunching))
    await clock.advance(by: .seconds(0.5))
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
    let didSaveNotices = ActorIsolated(false)
    
    var fileClient = FileClient.noop
    fileClient.save = { @Sendable _, _ in
      await didSaveNotices.setValue(true)
      return ()
    }
    
    let store = TestStore(
      initialState: .init(reportDraft: report),
      reducer: AppDomain(),
      prepareDependencies: { dependencies in
        dependencies.suspendingClock = ImmediateClock()
        dependencies.fileClient = fileClient
      }
    )
    
    await store.send(.fetchNoticesResponse(.success([]))) {
      $0.notices = .empty(.emptyNotices())
    }
    await didSaveNotices.withValue { value in
      XCTAssertFalse(value)
    }
  }
  
  func test_ActionFetchNoticeResponse_shouldStoreNoticeToFileClient() async {
   let didSaveNotices = ActorIsolated(false)
    
    var fileClient = FileClient.noop
    fileClient.save = { @Sendable _, _ in
      await didSaveNotices.setValue(true)
      return ()
    }
    
    let store = TestStore(
      initialState: .init(reportDraft: report),
      reducer: AppDomain()
    )
    store.dependencies.fileClient = fileClient
    store.dependencies.apiService.getNotices = { _ in .placeholder }
    
    await store.send(.fetchNoticesResponse(.success(.placeholder))) {
      $0.notices = .results(.placeholder)
    }
    await didSaveNotices.withValue { value in
      XCTAssertTrue(value)
    }
  }
  
  func test_ActionOnAccountSettings_shouldPersistAccountsSettings() async {
    let store = TestStore(
      initialState: .init(reportDraft: report),
      reducer: AppDomain()
    )
    store.dependencies.keychainClient = .noop
    store.dependencies.suspendingClock = ImmediateClock()
    
    await store.send(.settings(.accountSettings(.setApiToken("TOKEN")))) {
      $0.settings.accountSettingsState.accountSettings.apiToken = "TOKEN"
      $0.reportDraft.apiToken = "TOKEN"
    }
  }
  
  func test_Action_onAppear_shouldFetchNoticesWhenTokenisAdded() async {
    var state = AppDomain.State(reportDraft: report)
    state.settings.accountSettingsState.accountSettings.apiToken = "TOKEN"
    
    let store = TestStore(
      initialState: state,
      reducer: AppDomain()
    )
    store.dependencies.keychainClient = .noop
    store.dependencies.suspendingClock = ImmediateClock()
    store.dependencies.apiService.getNotices = { _ in [.mock] }
    store.dependencies.fileClient.save = { @Sendable _ ,_ in () }
    store.dependencies.fileClient.load = { @Sendable key in
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
      initialState: .init(reportDraft: report),
      reducer: AppDomain()
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
    var state = AppDomain.State(reportDraft: report)
    state.notices = .results([.mock])
    
    let store = TestStore(
      initialState: state,
      reducer: AppDomain()
    )
    
    store.send(.fetchNotices(forceReload: false))
    // does not fetch notices again
  }
  
  func test_Action_fetchNotices_shouldReload_whenElementsHaveBeenLoaded_andForceReload() async {
    var state = AppDomain.State(reportDraft: report)
    state.notices = .results([.placeholder])
    
    let store = TestStore(
      initialState: state,
      reducer: AppDomain()
    )
    store.dependencies.apiService.getNotices = { _ in [.mock] }
    store.dependencies.fileClient.save = { @Sendable _, _ in () }
    
    await store.send(.fetchNotices(forceReload: true)) {
      $0.notices = .loading
    }
    await store.receive(.fetchNoticesResponse(.success([.mock]))) {
      $0.notices = .results([.mock])
    }
  }
}

extension AppDomain.State {
  init(reportDraft: ReportDomain.State) {
    self.init()
    self.reportDraft = reportDraft
  }
}
