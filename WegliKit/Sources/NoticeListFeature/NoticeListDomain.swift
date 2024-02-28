import ApiClient
import ComposableArchitecture
import DescriptionFeature
import FeedbackGeneratorClient
import FileClient
import Foundation
import Helper
import L10n
import SharedModels
import UIKit

@Reducer
public struct NoticeListDomain {
  public init() {}
  
  @Dependency(\.fileClient) public var fileClient
  @Dependency(\.apiService) public var apiService
  @Dependency(\.uuid) public var uuid
  @Dependency(\.date) public var date
  @Dependency(\.continuousClock) public var clock
  @Dependency(\.feedbackGenerator) public var feedbackGenerator
  @Dependency(\.dismiss) var dismiss
  
  public struct State: Equatable {
    public var notices: IdentifiedArrayOf<EditNoticeDomain.State> = []
    public var alert: AlertState<Action>?
    public var noticesSortState: SortOrder = .init()
    @BindingState public var isFetchingNotices = false
    @BindingState public var isNetworkAvailable = true
    @BindingState public var isSendingEditedNotice = false
    
    @PresentationState public var selection: EditNoticeDomain.State?
    public var errorState: ErrorState?
    public var emptyState: EmptyState<Action>?
    
    public var errorBarMessage: MessageBarType?
    
    public enum MessageBarType: Equatable {
      case error(message: String)
      case success
    }
    
    public var contentState: ContentState<IdentifiedArrayOf<EditNoticeDomain.State>, Action> {
      if let errorState {
        return .error(errorState)
      } else if let emptyState {
        return .empty(emptyState)
      } else if isFetchingNotices {
        return .loading
      } else {
        return .results(notices)
      }
    }
    
    public init(
      notices: IdentifiedArrayOf<EditNoticeDomain.State>,
      isNetworkAvailable: Bool = true,
      alert: AlertState<NoticeListDomain.Action>? = nil,
      isSendingEditedNotice: Bool = false
    ) {
      self.notices = notices
      self.isNetworkAvailable = isNetworkAvailable
      self.alert = alert
      self.isSendingEditedNotice = isSendingEditedNotice
    }
    
    // MARK: Sorting Helper
    func isSortActionDisabled(_ sortAction: SortAction) -> Bool {
      let elements = notices.elements
      let filteredCount: Int
      switch sortAction {
      case .noticeDate:
        filteredCount = elements.map(\.date).count
      case .status:
        filteredCount = elements.compactMap(\.notice.status).count
      case .registration:
        filteredCount = elements.compactMap(\.notice.registration).count
      case .createdAtDate:
        filteredCount = elements.compactMap(\.notice.createdAt).count
      }
      return filteredCount != elements.count || elements.count == 1
    }
    
    public enum AlertAction: Equatable {
      case errorMessage(String)
      case dismiss
    }
  }
  
  public struct SortOrder: Equatable, Codable {
    public var action: SortAction
    public var sortType: SortType
    
    public init(action: SortAction = .noticeDate, sortType: SortType = .ascending) {
      self.action = action
      self.sortType = sortType
    }
    
    var isAscending: Bool {
      sortType.isAscending
    }
  }
  
  @CasePathable
  public enum Action: Equatable, BindableAction {
    case onAppear
    
    case binding(BindingAction<State>)
    case destination(PresentationAction<Destination.Action>)
    case setSortOrder(SortAction, SortType?)
    
    case onNavigateToAccountSettingsButtonTapped
    case onNoticeItemTapped(Notice)

    case editNotice(PresentationAction<EditNoticeDomain.Action>)
    case editNoticeResponse(TaskResult<Notice>)
    
    case fetchNotices(forceReload: Bool)
    case fetchNoticesResponse(TaskResult<[Notice]>)
    
    case dismissAlert
    case displayMessageBar(State.MessageBarType?)
    
    case sortStateLoaded(TaskResult<NoticeListDomain.SortOrder>)
  }
  
  @Reducer
  public struct Destination: Equatable {
    public enum State: Equatable {
      case edit(EditNoticeDomain.State)
    }

    public enum Action: Equatable {
      case edit(EditNoticeDomain.Action)
    }

    public var body: some ReducerOf<Self> {
      Scope(state: \.edit, action: \.edit) {
        EditNoticeDomain()
      }
    }
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce<State, Action> { state, action in
      switch action {
      case .onAppear:
        return .run { send in
          await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
              await send(.fetchNotices(forceReload: false))
            }
            group.addTask {
              await send(
                .sortStateLoaded(
                  TaskResult { try await fileClient.loadSortState() }
                )
              )
            }
          }
        }
      
      case .sortStateLoaded(let result):
        let sortOrder = (try? result.value) ?? .init()
        state.noticesSortState = sortOrder
        return .none
        
      case .destination:
        return .none
      
      case .setSortOrder(let action, let sortType):
        state.noticesSortState.action = action
        if let type = sortType {
          state.noticesSortState.sortType = type
        }
        
        let notices = state.notices.elements
        switch action {
        case .noticeDate:
          let sortedNotices = notices.sorted {
            let aDate = $0.date
            let bDate = $1.date
            let sortOperator: (Date, Date) -> Bool =  state.noticesSortState.isAscending ? (>) : (<)
            return sortOperator(aDate, bDate)
          }
          state.notices = IdentifiedArray(uniqueElements: sortedNotices, id: \.id)
          
        case .createdAtDate:
          let sortedNotices = notices.sorted {
            guard 
              let aCreatedAtDate = $0.notice.createdAt,
              let bCreateAtDate = $1.notice.createdAt
            else {
              return false
            }
            let sortOperator: (Date, Date) -> Bool = state.noticesSortState.isAscending ? (>) : (<)
            return sortOperator(aCreatedAtDate, bCreateAtDate)
          }
          state.notices = IdentifiedArray(uniqueElements: sortedNotices, id: \.id)
          
        case .registration:
          let sortedNotices = notices.sorted {
            guard 
              let aRegistration = $0.notice.registration,
              let bRegistration = $1.notice.registration
            else { return false }
            
            let sortOperator: (String, String) -> Bool = state.noticesSortState.isAscending ? (>) : (<)
            return sortOperator(aRegistration, bRegistration)
          }
          state.notices = IdentifiedArray(uniqueElements: sortedNotices, id: \.id)
          
        case .status:
          let sortedNotices = notices.sorted {
            guard 
              let aStatus = $0.notice.status,
              let bStatus = $1.notice.status
            else { return false }
            
            let sortOperator: (Notice.Status, Notice.Status) -> Bool = state.noticesSortState.isAscending ? (>) : (<)
            return sortOperator(aStatus, bStatus)
          }
          state.notices = IdentifiedArray(uniqueElements: sortedNotices, id: \.id)
        }
        
        return .run { _ in
          try await fileClient.saveNotices(notices.map(\.notice))
        }
        
      case .fetchNotices(let forceReload):
        let elements = state.notices.elements
        if !elements.isEmpty, !forceReload {
          return .none
        }
        
        if !forceReload {
          state.isFetchingNotices = true
        }
        
        return .run { send in
          await send(
            .fetchNoticesResponse(
              TaskResult { try await apiService.getNotices(forceReload) }
            )
          )
        }
        
      case let .fetchNoticesResponse(.success(notices)):
        state.isFetchingNotices = false
        let states = notices.map { EditNoticeDomain.State(notice: $0) }
        if states.isEmpty {
          state.emptyState = .emptyNotices()
          return .none
        }
        
        state.notices = IdentifiedArray(uniqueElements: states, id: \.id)
        
        guard !notices.isEmpty else  {
          return .none
        }
        
        return .send(.setSortOrder(state.noticesSortState.action, nil))
        
      case let .fetchNoticesResponse(.failure(error)):
        state.isFetchingNotices = false
        
        if let apiError = error as? ApiError {
          if apiError == .tokenUnavailable {
            state.errorState = .tokenUnavailable
            return .none
          } else {
            state.errorState = .loadingError(error: .init(error: apiError))
          }
        }
        return .none
        
      case .displayMessageBar(let value):
        state.errorBarMessage = value
        return .none
        
      case .onNavigateToAccountSettingsButtonTapped:
        return .none
        
      case .onNoticeItemTapped(let notice):
        state.selection = EditNoticeDomain.State(notice: notice)
        return .none
        
      case .editNoticeResponse(let response):
        state.isSendingEditedNotice = false
        
        switch response {
        case .success:
          return .run { send in
            await send(.fetchNotices(forceReload: true))
            await feedbackGenerator.notify(.success)
          }
          
        case .failure:
          state.alert = .editNoticeFailure
          return .run { _ in
            await feedbackGenerator.notify(.error)
          }
        }
        
      case .editNotice(let editNoticeAction):
        switch editNoticeAction {
        case .presented(.editNoticeResponse(.success)), .presented(.deleteNoticeResponse(.success)):
          return .run { send in
            await send(.fetchNotices(forceReload: true))
          }

        default:
          return .none
        }
        
      case .dismissAlert:
        state.alert = nil
        return .none
        
      case .binding:
        return .none
      }
    }
    .onChange(of: \.noticesSortState) { oldValue, newValue in
      Reduce { state, action in
          .run { _ in
            do {
              try await fileClient.saveSortState(newValue)
            } catch {
//              Logger.shared.log("Failed to store sort state")
            }
          }
      }
    }
    .ifLet(\.$selection, action: \.editNotice) {
      EditNoticeDomain()
    }
  }
}


// MARK: - Helper
let noticeDomainSortOrderKey = "noticeDomainSortOrderKey"
extension FileClient {
  func saveSortState(_ state: NoticeListDomain.SortOrder) async throws {
    guard let data = try? JSONEncoder().encode(state) else {
      return
    }
    try await self.save(noticeDomainSortOrderKey, data)
  }
  
  func loadSortState() async throws -> NoticeListDomain.SortOrder {
    guard
      let data = try? await load(noticeDomainSortOrderKey),
      let sortOrderState = try? JSONDecoder().decode(NoticeListDomain.SortOrder.self, from: data)
    else {
      throw NSError(domain: "NoticeListCore", code: -1)
    }
    return sortOrderState
  }
}

enum LoadingState {}
enum ObserveConnectionIdentifier {}

public extension AlertState where Action == NoticeListDomain.Action {
  static let editNoticeFailure = Self(
    title: .init("Fehler"),
    message: .init("Die Meldung konnte nicht gespeichert werden"),
    buttons: [
      .default(.init("Ok")),
      .default(.init("Wiederholen"), action: .send(.fetchNotices(forceReload: true)))
    ]
  )
  
  static let confirmDeleteNotice = Self(
    title: .init("Löschen bestätigen"),
    buttons: [
      .destructive(.init("Löschen")),
      .default(.init("Abbrechen"), action: .send(.dismissAlert))
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
  static func emptyNotices() -> EmptyState<NoticeListDomain.Action> {
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
      registration: editState.description.licensePlateNumber,
      brand: editState.description.carBrandSelection.selectedBrand?.title ?? "",
      color: DescriptionDomain.colors[editState.description.selectedColor].key,
      charge: editState.description.chargeSelection.selectedCharge.flatMap { DescriptionDomain.noticeCharge(with: $0.id) },
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
      over28Tons: editState.description.over28Tons,
      photos: editState.notice.photos ?? []
    )
  }
  
  public static let preview = Self(
    token: UUID().uuidString,
    status: .analyzing,
    street: "",
    city: "",
    zip: "",
    latitude: 0,
    longitude: 0,
    registration: "XX-XX-123",
    brand: "",
    color: "",
    charge: .init(tbnr: ""),
    date: .now,
    duration: 2,
    severity: nil,
    note: "",
    createdAt: .now,
    updatedAt: .now,
    sentAt: .now,
    vehicleEmpty: false,
    hazardLights: false,
    expiredTuv: false,
    expiredEco: false,
    photos: [.loadingPreview1, .loadingPreview2]
  )
  
  public static func placeholder(id: String = UUID().uuidString) -> Self {
    Self(
      token: id,
      status: .analyzing,
      street: "",
      city: "",
      zip: "",
      latitude: 0,
      longitude: 0,
      registration: "XX-XX-123",
      brand: "",
      color: "",
      charge: .init(tbnr: ""),
      date: .now,
      duration: 2,
      severity: nil,
      note: "",
      createdAt: .now,
      updatedAt: .now,
      sentAt: .now,
      vehicleEmpty: false,
      hazardLights: false,
      expiredTuv: false,
      expiredEco: false,
      photos: [.loadingPreview1, .loadingPreview2]
    )
  }
}

public enum SortType: Equatable, Codable {
  case ascending, descending
  
  var isAscending: Bool {
    switch self {
    case .ascending: true
    case .descending: false
    }
  }
  
  var toggled: Self {
    switch self {
    case .ascending:
        .descending
    case .descending:
        .ascending
    }
  }
  
  func sortType() -> (Date, Date) -> Bool {
    switch self {
    case .ascending:
      (>)
    case .descending:
      (<)
    }
  }
}

public enum SortAction: CaseIterable, Equatable, Codable {
  case noticeDate
  case status
  case registration
  case createdAtDate
    
  public var text: String {
    switch self {
    case .noticeDate:
      return "Tatzeit"
    case .status:
      return "Status"
    case .registration:
      return "Kennzeichen"
    case .createdAtDate:
      return "Erstellt"
    }
  }
}
