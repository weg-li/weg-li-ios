// Created for weg-li in 2021.

import ApiClient
import Combine
import ComposableArchitecture
import ComposableCoreLocation
import Contacts
import DescriptionFeature
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
    
    public var isNetworkAvailable = true { // TODO:
      didSet {
        reportDraft.isNetworkAvailable = isNetworkAvailable
      }
    }
    
    public var isFetchingNotices: Bool { notices == .loading }
    
    @BindingState public var selectedTab: Tabs = .notice
    public var noticesSortOrder: NoticeSortOrder = .noticeDate
    public var orderSortType: [NoticeSortOrder: Bool] = [
      .noticeDate: true,
      .createdAtDate: false,
      .registration: false,
      .status: false
    ]
    
    public var editNotice: EditNoticeDomain.State?
    public func isAscending(for type: NoticeSortOrder) -> Bool {
      orderSortType[type, default: true]
    }
    public var isSendingEditedNotice = false
    public var destination: Destination? {
      didSet {
        switch destination {
        case .edit(let notice):
          editNotice = .init(notice: notice)
        default:
          return
        }
      }
    }
    public var alert: AlertState<Action>?
    
    public enum Destination: Equatable {
      case edit(Notice)
      case alert(AlertState<AlertAction>)
    }
    public enum AlertAction: Equatable {
      case errorMessage(String)
      case dismiss
    }
    public enum NoticeSortOrder: Hashable {
      case createdAtDate
      case noticeDate
      case registration
      case status
    }
  }
  
  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
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
    case setSortOrder(State.NoticeSortOrder)
    case observeConnectionResponse(NetworkPath)
    case setNavigationDestination(State.Destination?)
    case onSaveNoticeButtonTapped
    case editNoticeResponse(TaskResult<Notice>)
    case editNotice(EditNoticeDomain.Action)
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
        
      case .setSortOrder(let order):
        guard let notices = state.notices.elements else {
          return .none
        }
        
        state.noticesSortOrder = order
                        
        switch order {
        case .noticeDate:
          let orderAscending = state.orderSortType[order, default: true]
          let sortedNotices = notices.sorted {
            guard let aDate = $0.date, let bDate = $1.date else { return false }
            let sortOperator: (Date, Date) -> Bool = orderAscending ? (>) : (<)
            return sortOperator(aDate, bDate)
          }
          state.orderSortType[order] = !orderAscending
          state.notices = .results(sortedNotices)
        
        case .createdAtDate:
          let orderAscending = state.orderSortType[order, default: true]
          let sortedNotices = notices.sorted {
            guard let aCreatedAtDate = $0.createdAt, let bCreateAtDate = $1.createdAt else { return false }
            let sortOperator: (Date, Date) -> Bool = orderAscending ? (>) : (<)
            return sortOperator(aCreatedAtDate, bCreateAtDate)
          }
          state.orderSortType[order] = !orderAscending
          state.notices = .results(sortedNotices)
          
        case .registration:
          let orderAscending = state.orderSortType[order, default: true]
          let sortedNotices = notices.sorted {
            guard let aRegistration = $0.registration, let bRegistration = $1.registration else { return false }
            let sortOperator: (String, String) -> Bool = orderAscending ? (>) : (<)
            return sortOperator(aRegistration, bRegistration)
          }
          state.orderSortType[order] = !orderAscending
          state.notices = .results(sortedNotices)
          
        case .status:
          let orderAscending = state.orderSortType[order, default: true]
          let sortedNotices = notices.sorted {
            guard let aStatus = $0.status, let bStatus = $1.status else { return false }
            let sortOperator: (Notice.Status, Notice.Status) -> Bool = orderAscending ? (>) : (<)
            return sortOperator(aStatus, bStatus)
          }
          state.orderSortType[order] = !orderAscending
          state.notices = .results(sortedNotices)
        }
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
        return EffectTask(value: .fetchNotices(forceReload: false))
        
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
          state.reportDraft.alwaysSendNotice = state.settings.userSettings.alwaysSendNotice
          return .none
        
        case .accountSettings:
          state.reportDraft.apiToken = state.settings.accountSettingsState.accountSettings.apiToken
          return .none
          
        default:
          return .none
        }
        
        // After the emailResult reports the mail has been sent the report will be stored.
      case .report(.mail(.setMailResult(.sent))):
        state.reportDraft.images.storedPhotos.removeAll()
        let safeImageUrls = state.reportDraft.images.storedPhotos
          .compactMap {  $0 }
          .compactMap(\.imageUrl)
        return .merge(
          .fireAndForget {
            for url in safeImageUrls {
              try await fileClient.removeItem(url)
            }
          },
          EffectTask(value: .reportSaved)
        )
        
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
        let sortedNotices = notices.sorted {
          guard let aDate = $0.date, let bDate = $1.date else { return false }
          return aDate > bDate
        }
        state.notices = notices.isEmpty ? .empty(.emptyNotices()) : .results(sortedNotices)
        
        guard !sortedNotices.isEmpty else  {
          return .none
        }
        
        return .fireAndForget {
          try await fileClient.saveNotices(sortedNotices)
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

      case .setNavigationDestination(let value):
        state.destination = value
        return .none
        
      case .onSaveNoticeButtonTapped:
        state.isSendingEditedNotice = true
        
        guard let notice = state.editNotice else {
          return .none
        }
        let patch = Notice(notice)
        
        return .task {
          await .editNoticeResponse(
            TaskResult {
              try await apiService.patchNotice(patch)
            }
          )
        }
        
      case .editNoticeResponse(let response):
        state.isSendingEditedNotice = false
        
        switch response {
        case .success:
          state.destination = nil
          return .task { .fetchNotices(forceReload: true) }
          
        case .failure:
          state.alert = .editNoticeFailure
          return .none
        }
        
      case .editNotice:
        return .none
        
      case .dismissAlert:
        state.alert = nil
        return .none
      }
    }
    .ifLet(\.editNotice, action: /Action.editNotice) {
      EditNoticeDomain()
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
  static let editNoticeFailure = Self(
    title: .init("Fehler"),
    message: .init("Die Meldung konnte nicht gespeichert werden"),
    buttons: [
      .default(.init("Ok")),
      .default(.init("Wiederholen"), action: .send(.fetchNotices(forceReload: true)))
    ]
  )
  
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

extension Notice {
  init(_ editState: EditNoticeDomain.State) {
    self.init(
      token: editState.notice.id,
      status: editState.notice.status ?? .open,
      street: editState.street,
      city: editState.city,
      zip: editState.zip,
      latitude: editState.notice.latitude ?? 0,
      longitude: editState.notice.longitude ?? 0,
      registration: editState.notice.registration ?? "",
      brand: editState.description.carBrandSelection.selectedBrand?.title ?? "",
      color: DescriptionDomain.colors[editState.description.selectedColor].key,
      charge: editState.description.chargeSelection.selectedCharge?.text ?? "",
      date: editState.date,
      duration: Int64(editState.description.selectedDuration),
      severity: nil,
      note: editState.description.note,
      createdAt: editState.notice.createdAt ?? .now,
      updatedAt: Date(),
      sentAt: Date(),
      vehicleEmpty: editState.description.vehicleEmpty,
      hazardLights: editState.description.hazardLights,
      expiredTuv: editState.description.expiredTuv,
      expiredEco: editState.description.expiredEco,
      photos: editState.notice.photos ?? []
    )
  }
}
