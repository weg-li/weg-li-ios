// Created for weg-li in 2021.

import ApiClient
import Combine
import ComposableArchitecture
import ComposableCoreLocation
import Contacts
import FileClient
import Helper
import Foundation
import ImagesFeature
import KeychainClient
import MapKit
import OrderedCollections
import PlacesServiceClient
import ReportFeature
import SettingsFeature
import SharedModels
import UIKit
import Network

// MARK: - AppState

public struct AppState: Equatable {
  /// Settings
  public var settings: SettingsState
  
  public var notices: ContentState<[Notice]>
  
  /// Holds a report that has not been stored or sent via mail
  public var reportDraft: ReportState = .init(
    uuid: UUID.init,
    images: .init(),
    contactState: .empty,
    date: Date.init
  )
  
  var showReportWizard = false
  public var isFetchingNotices = false
  
  public init(
    settings: SettingsState = .init(
      accountSettingsState: .init(accountSettings: .init(apiToken: "")),
      contact: .empty,
      userSettings: .init(showsAllTextRecognitionSettings: false)
    ),
    notices: ContentState<[Notice]> = .loading,
    showReportWizard: Bool = false
  ) {
    self.settings = settings
    self.notices = notices
    self.showReportWizard = showReportWizard
  }
  
}

// MARK: - AppAction

public enum AppAction: Equatable {
  case appDelegate(AppDelegateAction)
  case contactSettingsLoaded(Result<Contact, NSError>)
  case storedNoticesLoaded(Result<[Notice], NSError>)
  case userSettingsLoaded(Result<UserSettings, NSError>)
  case storedApiTokenLoaded(Result<String?, NSError>)
  case settings(SettingsAction)
  case report(ReportAction)
  case showReportWizard(Bool)
  case fetchNotices
  case fetchNoticesResponse(Result<[Notice], ApiError>)
  case reportSaved
  case onAppear
}

// MARK: - Environment

public struct AppEnvironment {
  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    fileClient: FileClient,
    keychainClient: KeychainClient,
    apiClient: APIClient,
    wegliService: WegliAPIService,
    date: @escaping () -> Date = Date.init,
    uuid: @escaping () -> UUID = UUID.init
  ) {
    self.mainQueue = mainQueue
    self.backgroundQueue = backgroundQueue
    self.fileClient = fileClient
    self.keychainClient = keychainClient
    self.apiClient = apiClient
    self.wegliService = wegliService
    self.date = date
    self.uuid = uuid
  }
  
  public let mainQueue: AnySchedulerOf<DispatchQueue>
  public let backgroundQueue: AnySchedulerOf<DispatchQueue>
  public let fileClient: FileClient
  public let keychainClient: KeychainClient
  public var apiClient: APIClient
  public let wegliService: WegliAPIService
  
  public var date: () -> Date
  public var uuid: () -> UUID
}

public extension AppEnvironment {
  static let live = Self(
    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
    backgroundQueue: DispatchQueue(label: "background-queue").eraseToAnyScheduler(),
    fileClient: .live,
    keychainClient: .live(),
    apiClient: .live,
    wegliService: .live()
  )
}

/// Reducer handling actions from the HomeView and combining it with the reducers from descending screens.
public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  reportReducer
    .pullback(
      state: \.reportDraft,
      action: /AppAction.report,
      environment: {
        ReportEnvironment(
          mainQueue: $0.mainQueue,
          backgroundQueue: $0.backgroundQueue,
          locationManager: .live,
          placeService: .live,
          regulatoryOfficeMapper: .live(),
          fileClient: $0.fileClient,
          wegliService: $0.wegliService,
          date: $0.date
        )
      }
    ),
  settingsReducer.pullback(
    state: \.settings,
    action: /AppAction.settings,
    environment: { parent in
      SettingsEnvironment(
        uiApplicationClient: .live,
        keychainClient: parent.keychainClient,
        apiClient: parent.apiClient,
        wegliService: parent.wegliService,
        mainQueue: parent.mainQueue
      )
    }
  ),
  Reducer { state, action, environment in
    switch action {
    case .appDelegate:
      return .merge(
        .concatenate(
          environment.fileClient.loadContactSettings()
            .map(AppAction.contactSettingsLoaded),
          environment.fileClient.loadUserSettings()
            .map(AppAction.userSettingsLoaded),
          environment.keychainClient.getApiToken()
            .map(AppAction.storedApiTokenLoaded)
        )
      )
      
    case .onAppear:
        return .none
      
    case let .contactSettingsLoaded(result):
      let contact = (try? result.get()) ?? .init()
      state.settings.contact = .init(contact: contact, alert: nil)
      return .none
      
    case let .storedNoticesLoaded(result):
      let notices = (try? result.get()) ?? []
      state.notices = notices.isEmpty
      ? .empty(.emptyNotices)
      : .results(notices)
      return .none
      
    case let .storedApiTokenLoaded(result):
      let apiToken = (try? result.get()) ?? ""
      state.settings.accountSettingsState.accountSettings.apiToken = apiToken
      state.reportDraft.apiToken = apiToken
      return Effect(value: .fetchNotices)
      
    case let .userSettingsLoaded(result):
      let userSettings = (try? result.get()) ?? UserSettings(showsAllTextRecognitionSettings: false)
      state.settings.userSettings = userSettings
      state.reportDraft.images.showsAllTextRecognitionResults = userSettings.showsAllTextRecognitionSettings
      return .none
      
    case .settings:
      return .none
      
      // After the emailResult reports the mail has been sent the report will be stored.
    case .report(.mail(.setMailResult(.sent))):
      state.reportDraft.images.storedPhotos.forEach { image in
        _ = try? image?.imageUrl.flatMap { safeUrl in
          try FileManager.default.removeItem(at: safeUrl)
        }
      }
      state.reportDraft.images.storedPhotos.removeAll()
      state.showReportWizard = false
      
      return Effect(value: AppAction.reportSaved)
      
    case .report(.resetConfirmButtonTapped):
      state.reportDraft = ReportState(
        uuid: environment.uuid,
        images: .init(),
        contactState: state.settings.contact,
        date: environment.date, 
        location: .init()
      )
      return .none
    
    case .report:
      return .none
  
    case let .showReportWizard(value):
      if !state.reportDraft.isModified() {
        var imagesState: ImagesViewState = .init()
        imagesState.showsAllTextRecognitionResults = state.settings.userSettings.showsAllTextRecognitionSettings
        state.reportDraft = .init(
          uuid: environment.uuid,
          images: imagesState,
          contactState: state.settings.contact,
          date: environment.date
        )
      }
      state.showReportWizard = value
      return .none
      
    case .fetchNotices:
      let apiToken = state.settings.accountSettingsState.accountSettings.apiToken
      
      state.notices = .loading
      
      return environment.wegliService.getNotices()
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(AppAction.fetchNoticesResponse)
      
    case let .fetchNoticesResponse(.success(notices)):
      state.isFetchingNotices = false
            
      state.notices = notices.isEmpty
      ? .empty(.emptyNotices)
      : .results(notices)
      
      return environment.fileClient
        .saveNotices(notices, on: environment.backgroundQueue)
        .receive(on: environment.mainQueue)
        .fireAndForget()
      
    case let .fetchNoticesResponse(.failure(error)):
      state.isFetchingNotices = false
      state.notices = .error(.init(title: "Fehler", body: error.message))
      return .none
      
    case .reportSaved:
      // Reset report draft after it was saved
      state.reportDraft = ReportState(
        uuid: environment.uuid,
        images: .init(),
        contactState: state.settings.contact,
        date: environment.date
      )
      return .none
    }
  }
)
.onChange(of: \.reportDraft.contactState.contact) { contact, state, _, environment in
  struct SaveDebounceId: Hashable {}
  state.settings.contact.contact = contact

  return environment.fileClient
    .saveContactSettings(contact, on: environment.backgroundQueue)
    .fireAndForget()
    .debounce(id: SaveDebounceId(), for: .seconds(1), scheduler: environment.mainQueue)
}
.onChange(of: \.settings.contact) { contact, state, _, environment in
  struct SaveDebounceId: Hashable {}
  state.reportDraft.contactState = contact

  return environment.fileClient
    .saveContactSettings(contact.contact, on: environment.backgroundQueue)
    .fireAndForget()
    .debounce(id: SaveDebounceId(), for: .seconds(1), scheduler: environment.mainQueue)
}
.onChange(of: \.settings.userSettings) { settings, state, _, environment in
  struct SaveDebounceId: Hashable {}
  state.reportDraft.images.showsAllTextRecognitionResults = settings.showsAllTextRecognitionSettings
  
  return environment.fileClient
    .saveUserSettings(settings, on: environment.backgroundQueue)
    .fireAndForget()
    .debounce(id: SaveDebounceId(), for: .seconds(1), scheduler: environment.mainQueue)
}
.onChange(of: \.settings.accountSettingsState.accountSettings) { accountSettings, state, _, environment in
  state.reportDraft.apiToken = accountSettings.apiToken
  return .none
}


// MARK: Helper
extension AppState {
  static let preview = AppState()
}

public extension Array where Element == Notice {
  static let placeholder: [Element] = Array(repeating: Notice(ReportState.preview), count: 6)
}

extension Store where State == AppState, Action == AppAction {
  static let placeholder = Store(
    initialState: .init(
      settings: .init(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        contact: .preview,
        userSettings: .init()),
      notices: .results(.placeholder),
      showReportWizard: false
    ),
    reducer: .empty,
    environment: ()
  )
}
