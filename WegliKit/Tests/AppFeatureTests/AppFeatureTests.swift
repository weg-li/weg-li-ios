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
  }
  
  func test_updateContact_ShouldUpdateState() async {
    let store = TestStore(
      initialState: AppDomain.State(),
      reducer: AppDomain()
    )
    store.dependencies.fileClient = .noop
    store.dependencies.continuousClock = ImmediateClock()
    
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
    
    var wegliService = APIService.noop
    wegliService.getNotices = { _ in [.mock]}
    
    let store = TestStore(
      initialState: state,
      reducer: AppDomain(),
      prepareDependencies: { dependencies in
        dependencies.keychainClient = keychainClient
        dependencies.apiService = wegliService
        dependencies.continuousClock = clock
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
    
    await store.send(.internalAction(.appDelegate(.didFinishLaunching)))
    await clock.advance(by: .seconds(0.5))
    await store.receive(.internalAction(.contactSettingsLoaded(.success(.preview)))) {
      $0.contact = .preview
      $0.reportDraft.contactState.contact = .preview
    }
    await store.receive(.internalAction(.userSettingsLoaded(.success(state.settings.userSettings))))
    await store.receive(.internalAction(.storedApiTokenLoaded(.success(token)))) {
      $0.reportDraft.apiToken = token
      $0.settings.accountSettingsState.accountSettings.apiToken = token
    }
    await store.finish()
  }
  
  func test_ActionOnAccountSettings_shouldPersistAccountsSettings() async {
    let store = TestStore(
      initialState: .init(reportDraft: report),
      reducer: AppDomain()
    )
    store.dependencies.keychainClient = .noop
    store.dependencies.continuousClock = ImmediateClock()
    
    await store.send(.settings(.accountSettings(.setApiToken("TOKEN")))) {
      $0.settings.accountSettingsState.accountSettings.apiToken = "TOKEN"
      $0.reportDraft.apiToken = "TOKEN"
    }
  }
  
  func test_onNavigateToAccountSettingsButtonTapped() async {
    var store = TestStore(
      initialState: .init(reportDraft: report),
      reducer: AppDomain()
    )
    store.exhaustivity = .off
    
    await store.send(.noticeList(.onNavigateToAccontSettingsButtonTapped))
    await store.receive(.viewAction(.setSelectedTab(.settings))) {
      $0.selectedTab = .settings
    }
    await store.receive(.settings(.setDestination(.accountSettings))) {
      $0.settings.destination = .accountSettings
    }
  }
}

extension AppDomain.State {
  init(reportDraft: ReportDomain.State) {
    self.init()
    self.reportDraft = reportDraft
  }
}
