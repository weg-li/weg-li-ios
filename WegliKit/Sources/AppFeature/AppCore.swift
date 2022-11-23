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

public struct AppDomain: ReducerProtocol {
  public init() {}
  
  @Dependency(\.continuousClock) public var clock
  @Dependency(\.fileClient) public var fileClient
  @Dependency(\.keychainClient) public var keychainClient
  @Dependency(\.apiService) public var apiService
  @Dependency(\.uuid) public var uuid
  @Dependency(\.date) public var date
  @Dependency(\.pathMonitorClient) public var pathMonitorClient
  
  public struct State: Equatable {
    /// Settings
    public var settings: SettingsDomain.State
    public var contact: Contact = .empty
    public var notices: ContentState<[Notice], Action>
    
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
    
    public var alert: AlertState<Action>?
  }
  
  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<AppDomain.State>)
    case appDelegate(AppDelegateDomain.Action)
    case contactSettingsLoaded(TaskResult<Contact>)
    case userSettingsLoaded(TaskResult<UserSettings>)
    case storedApiTokenLoaded(TaskResult<String?>)
    case settings(SettingsDomain.Action)
    case report(ReportDomain.Action)
    case fetchNotices(forceReload: Bool)
    case fetchNoticesResponse(TaskResult<[Notice]>)
    case reportSaved
    case onAppear
    case observeConnection
    case observeConnectionResponse(NetworkPath)
    case dismissAlert
  }
  
  public var body: some ReducerProtocol<State, Action> {
    Scope(state: \.reportDraft, action: /Action.report) {
      ReportDomain()
    }
    
    Scope(state: \.settings, action: /Action.settings) {
      SettingsDomain()
    }
    
    BindingReducer()
    
    Reduce<State, Action> { state, action in
      switch action {
      case .binding:
        return .none
        
      case .appDelegate:
        return .run { send in
          await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
              await send(
                .contactSettingsLoaded(
                  TaskResult { try await fileClient.loadContactSettings() }
                )
              )
            }
            
            group.addTask {
              await send(
                .userSettingsLoaded(
                  TaskResult { try await fileClient.loadUserSettings() }
                )
              )
            }
            
            group.addTask {
              await send(
                .storedApiTokenLoaded(
                  TaskResult { await keychainClient.getApiToken() }
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
        
      case .settings(let settingsAction):
        switch settingsAction {
        case .userSettings:
          // store usersettings when changed
          state.reportDraft.images.showsAllTextRecognitionResults = state.settings.userSettings.showsAllTextRecognitionSettings
          let userSettins = state.settings.userSettings
          return .fireAndForget {
            enum CancelID {}
            try await withTaskCancellation(id: CancelID.self, cancelInFlight: true) {
              try await clock.sleep(for: .seconds(0.3))
              try await fileClient.saveUserSettings(userSettins)
            }
          }
        
        case .accountSettings:
          state.reportDraft.apiToken = state.settings.accountSettingsState.accountSettings.apiToken
          return .none
          
        default:
          return .none
        }
        
        // After the emailResult reports the mail has been sent the report will be stored.
      case .report(.mail(.setMailResult(.sent))):
        state.reportDraft.images.storedPhotos.forEach { image in
          _ = try? image?.imageUrl.flatMap { safeUrl in
            try FileManager.default.removeItem(at: safeUrl)
          }
        }
        state.reportDraft.images.storedPhotos.removeAll()
        
        return Effect(value: .reportSaved)
        
      case .report(.onResetConfirmButtonTapped):
        state.reportDraft = ReportDomain.State(
          uuid: uuid.callAsFunction,
          images: .init(),
          contactState: .init(contact: state.contact),
          date: date.callAsFunction,
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
              try await apiService.getNotices(forceReload)
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
          try await fileClient.saveNotices(notices)
        }
        
      case let .fetchNoticesResponse(.failure(error)):
        state.notices = .error(.loadingError(error: .init(error: error)))
        return .none
        
      case .reportSaved:
        // Reset report draft after it was saved
        state.reportDraft = ReportDomain.State(
          uuid: uuid.callAsFunction,
          images: .init(),
          contactState: .init(contact: state.contact),
          date: date.callAsFunction
        )
        return .none
        
      case .observeConnection:
        return .run { send in
          for await path in await pathMonitorClient.networkPathPublisher() {
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
  }
}


public extension AppDomain.State {
  init(
    settings: SettingsDomain.State = .init(
      accountSettingsState: .init(accountSettings: .init(apiToken: "")),
      userSettings: .init(showsAllTextRecognitionSettings: false)
    ),
    notices: ContentState<[Notice], AppDomain.Action> = .loading
  ) {
    self.settings = settings
    self.notices = notices
  }
}

// MARK: Helper

enum ObserveConnectionIdentifier {}

public extension Array where Element == Notice {
  static let placeholder: [Element] = Array(repeating: Notice(ReportDomain.State.preview), count: 6)
}

extension Store where State == AppDomain.State, Action == AppDomain.Action {
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

public extension AlertState where Action == AppDomain.Action {
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
  static func emptyNotices() -> EmptyState<AppDomain.Action> {
    .init(
      text: "Keine Meldungen",
      message: .init(string: "Meldungen konnten nicht geladen werden"),
      action: .init(label: "Erneut laden", action: .fetchNotices(forceReload: false))
    )
  }
}
