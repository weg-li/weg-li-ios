// Created for weg-li in 2021.

import ApiClient
import Combine
import ComposableArchitecture
import ComposableCoreLocation
import Contacts
import FileClient
import Foundation
import Helper
import ImagesFeature
import KeychainClient
import L10n
import MapKit
import Network
import OrderedCollections
import PathMonitorClient
import PlacesServiceClient
import ReportFeature
import SettingsFeature
import SharedModels
import UIKit

public enum Tabs: Hashable {
  case notices
  case notice
  case settings
}

// MARK: - AppState

public struct AppState: Equatable {
  /// Settings
  public var settings: SettingsState
  public var contact: Contact = .empty
  public var notices: ContentState<[Notice], AppAction>
  
  /// Holds a report that has not been stored or sent via mail
  public var reportDraft: ReportDomain.State = .init(
    uuid: UUID.init,
    images: .init(),
    contactState: .empty,
    date: Date.init
  )
  
  public var isNetworkAvailable = true {
    didSet {
      reportDraft.isNetworkAvailable = isNetworkAvailable
    }
  }
  
  public var isFetchingNotices: Bool { notices == .loading }
  
  @BindableState public var selectedTab: Tabs = .notice
  
  public var alert: AlertState<AppAction>?
}

public extension AppState {
  init(
    settings: SettingsState = .init(
      accountSettingsState: .init(accountSettings: .init(apiToken: "")),
      userSettings: .init(showsAllTextRecognitionSettings: false)
    ),
    notices: ContentState<[Notice], AppAction> = .loading
  ) {
    self.settings = settings
    self.notices = notices
  }
}

// MARK: - AppAction

public enum AppAction: Equatable, BindableAction {
  case binding(BindingAction<AppState>)
  case appDelegate(AppDelegateAction)
  case contactSettingsLoaded(TaskResult<Contact>)
  case userSettingsLoaded(TaskResult<UserSettings>)
  case storedApiTokenLoaded(TaskResult<String?>)
  case settings(SettingsAction)
  case report(ReportAction)
  case fetchNotices(forceReload: Bool)
  case fetchNoticesResponse(TaskResult<[Notice]>)
  case reportSaved
  case onAppear
  case observeConnection
  case observeConnectionResponse(NetworkPath)
  case dismissAlert
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
    pathMonitorClient: PathMonitorClient,
    date: @escaping () -> Date = Date.init,
    uuid: @escaping () -> UUID = UUID.init
  ) {
    self.mainQueue = mainQueue
    self.backgroundQueue = backgroundQueue
    self.fileClient = fileClient
    self.keychainClient = keychainClient
    self.apiClient = apiClient
    self.wegliService = wegliService
    self.pathMonitorClient = pathMonitorClient
    self.date = date
    self.uuid = uuid
  }
  
  public let mainQueue: AnySchedulerOf<DispatchQueue>
  public let backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var fileClient: FileClient
  public let keychainClient: KeychainClient
  public var apiClient: APIClient
  public var wegliService: WegliAPIService
  public let pathMonitorClient: PathMonitorClient
  
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
    wegliService: .live(),
    pathMonitorClient: .live(queue: .main)
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
        mainQueue: parent.mainQueue
      )
    }
  ),
  Reducer { state, action, environment in
    switch action {
    case .binding:
      return .none
      
    case .appDelegate:
      return .run { send in
        await withThrowingTaskGroup(of: Void.self) { group in
          group.addTask {
            await send(
              .contactSettingsLoaded(
                TaskResult { try await environment.fileClient.loadContactSettings() }
              )
            )
          }
          
          group.addTask {
            await send(
              .userSettingsLoaded(
                TaskResult { try await environment.fileClient.loadUserSettings() }
              )
            )
          }
          
          group.addTask {
            await send(
              .storedApiTokenLoaded(
                TaskResult { await environment.keychainClient.getApiToken() }
              )
            )
          }
        }
      }
      
    case .onAppear:
      let isTokenAvailable = !state.settings.accountSettingsState.accountSettings.apiToken.isEmpty
      guard isTokenAvailable else {
        state.notices = .error(.tokenUnavailable)
        return .none
      }
      return Effect(value: .fetchNotices(forceReload: false))
      
    case let .contactSettingsLoaded(result):
      let contact = (try? result.value) ?? .init()
      state.contact = contact
      state.reportDraft.contactState.contact = contact
      return .none
      
    case let .storedApiTokenLoaded(result):
      let apiToken = (try? result.value) ?? ""
      state.settings.accountSettingsState.accountSettings.apiToken = apiToken
      state.reportDraft.apiToken = apiToken
      return .none
      
    case let .userSettingsLoaded(result):
      let userSettings = (try? result.value) ?? UserSettings(showsAllTextRecognitionSettings: false)
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
      
      return Effect(value: AppAction.reportSaved)
      
    case .report(.onResetConfirmButtonTapped):
      state.reportDraft = ReportDomain.State(
        uuid: environment.uuid,
        images: .init(),
        contactState: .init(contact: state.contact),
        date: environment.date,
        location: .init()
      )
      return .none
      
    case .report(.contact):
      state.contact = state.reportDraft.contactState.contact
      return .none
      
    case .report:
      return .none
      
    case let .fetchNotices(forceReload):
      guard state.isNetworkAvailable else {
        state.alert = .noInternetConnection
        state.notices = .empty(.emptyNotices())
        return .none
      }
      
      // dont reload every time
      if let elements = state.notices.elements, !elements.isEmpty, !forceReload {
        return .none
      }
      
      state.notices = .loading
      
      return .task {
        await .fetchNoticesResponse(
          TaskResult {
            try await environment.wegliService.getNotices(forceReload)
          }
        )
      }
      
    case let .fetchNoticesResponse(.success(notices)):
      state.notices = notices.isEmpty
      ? .empty(.emptyNotices())
      : .results(notices)
      
      guard !notices.isEmpty else  {
        return .none
      }
      
      return .fireAndForget {
        try await environment.fileClient.saveNotices(notices)
      }
      
    case let .fetchNoticesResponse(.failure(error)):
      state.notices = .error(.loadingError(error: .init(error: error)))
      return .none
      
    case .reportSaved:
      // Reset report draft after it was saved
      state.reportDraft = ReportDomain.State(
        uuid: environment.uuid,
        images: .init(),
        contactState: .init(contact: state.contact),
        date: environment.date
      )
      return .none
      
    case .observeConnection:
      return .run { send in
        for await path in await environment.pathMonitorClient.networkPathPublisher() {
          await send(.observeConnectionResponse(path))
        }
      }
      .cancellable(id: ObserveConnectionIdentifier.self)
      
    case let .observeConnectionResponse(networkPath):
      state.isNetworkAvailable = networkPath.status == .satisfied
      return .none
      
    case .dismissAlert:
      state.alert = nil
      return .none
    }
  }
)
.binding()
// store contact settings when changed in settings
.onChange(of: \.contact) { contact, state, _, environment in
  .fireAndForget {
    enum CancelID {}
    try await withTaskCancellation(id: CancelID.self, cancelInFlight: true) {
      try await environment.mainQueue.sleep(for: .seconds(0.3))
      try await environment.fileClient.saveContactSettings(contact)
    }
  }
}
// store usersettings when changed
.onChange(of: \.settings.userSettings) { settings, state, _, environment in
  state.reportDraft.images.showsAllTextRecognitionResults = settings.showsAllTextRecognitionSettings
  
  return .fireAndForget {
    enum CancelID {}
    try await withTaskCancellation(id: CancelID.self, cancelInFlight: true) {
      try await environment.mainQueue.sleep(for: .seconds(0.3))
      try await environment.fileClient.saveUserSettings(settings)
    }
  }
}
.onChange(of: \.settings.accountSettingsState.accountSettings) { accountSettings, state, _, _ in
  state.reportDraft.apiToken = accountSettings.apiToken
  return .none
}

// MARK: Helper

enum ObserveConnectionIdentifier {}

extension AppState {
  static let preview = AppState()
}

public extension Array where Element == Notice {
  static let placeholder: [Element] = Array(repeating: Notice(ReportDomain.State.preview), count: 6)
}

extension Store where State == AppState, Action == AppAction {
  static let placeholder = Store(
    initialState: .init(
      settings: .init(
        accountSettingsState: .init(accountSettings: .init(apiToken: "")),
        userSettings: .init()
      ),
      notices: .results(.placeholder)
    ),
    reducer: .empty,
    environment: ()
  )
}

public extension AlertState where Action == AppAction {
  static let noInternetConnection = Self(
    title: .init("Keine Internetverbindung"),
    message: .init("Verbinde dich mit dem Internet um deine Meldungen zu laden"),
    buttons: [
      .cancel(.init(L10n.cancel)),
      .default(.init("Wiederholen"), action: .send(.fetchNotices(forceReload: true)))
    ]
  )
}

public extension EmptyState {
  static func emptyNotices() -> EmptyState<AppAction> {
    .init(
      text: "Keine Meldungen",
      message: .init(string: "Meldungen konnten nicht geladen werden"),
      action: .init(label: "Erneut laden", action: .fetchNotices(forceReload: false))
    )
  }
}
