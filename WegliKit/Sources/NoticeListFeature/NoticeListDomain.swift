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

public struct NoticeListDomain: Reducer {
  public init() {}
  
  @Dependency(\.fileClient) public var fileClient
  @Dependency(\.apiService) public var apiService
  @Dependency(\.uuid) public var uuid
  @Dependency(\.date) public var date
  @Dependency(\.continuousClock) public var clock
  @Dependency(\.feedbackGenerator) public var feedbackGenerator
  @Dependency(\.dismiss) var dismiss
  
  public struct State: Equatable {
    public var notices: ContentState<[Notice], Action>
    public var editNotice: EditNoticeDomain.State?
    public var alert: AlertState<Action>?
    public var noticesSortOrder: NoticeSortOrder = .noticeDate
    public var orderSortType: [NoticeSortOrder: Bool]
    @BindingState public var isFetchingNotices = false
    @BindingState public var isNetworkAvailable = true
    @BindingState public var isSendingEditedNotice = false
    
    @PresentationState var destination: Destination.State?
    
    public var errorBarMessage: MessageBarType?
    
    public enum MessageBarType: Equatable {
      case error(message: String)
      case success
    }
    
    public init(
      notices: ContentState<[Notice],
      NoticeListDomain.Action>,
      editNotice: EditNoticeDomain.State? = nil,
      isNetworkAvailable: Bool = true,
      alert: AlertState<NoticeListDomain.Action>? = nil,
      noticesSortOrder: NoticeListDomain.State.NoticeSortOrder = .noticeDate,
      orderSortType: [NoticeListDomain.State.NoticeSortOrder : Bool] = [
        .noticeDate: true,
        .createdAtDate: false,
        .registration: false,
        .status: false
      ],
      isSendingEditedNotice: Bool = false
    ) {
      self.notices = notices
      self.editNotice = editNotice
      self.isNetworkAvailable = isNetworkAvailable
      self.alert = alert
      self.noticesSortOrder = noticesSortOrder
      self.orderSortType = orderSortType
      self.isSendingEditedNotice = isSendingEditedNotice
    }
    
    // MARK: Sorting Helper
    public func isAscending(for type: NoticeSortOrder) -> Bool {
      orderSortType[type, default: true]
    }
    
    func isSortActionDisabled(_ sortAction: SortAction) -> Bool {
      guard let elements = notices.elements else { return true }
      let filteredCount: Int
      switch sortAction {
      case .noticeDate:
        filteredCount = elements.compactMap(\.date).count
      case .status:
        filteredCount = elements.compactMap(\.status).count
      case .registration:
        filteredCount = elements.compactMap(\.registration).count
      case .createdAtDate:
        filteredCount = elements.compactMap(\.createdAt).count
      }
      return filteredCount != elements.count || elements.count == 1
    }
    
    public enum NoticeSortOrder: Hashable {
      case createdAtDate
      case noticeDate
      case registration
      case status
    }
    
    public enum AlertAction: Equatable {
      case errorMessage(String)
      case dismiss
    }
  }
  
  @CasePathable
  public enum Action: Equatable, BindableAction {
    case onAppear
    
    case binding(BindingAction<State>)
    case destination(PresentationAction<Destination.Action>)
    case setSortOrder(State.NoticeSortOrder)
    
    case onNavigateToAccountSettingsButtonTapped
    case onNoticeItemTapped(Notice)

    case editNotice(EditNoticeDomain.Action)
    case editNoticeResponse(TaskResult<Notice>)
    
    case fetchNotices(forceReload: Bool)
    case fetchNoticesResponse(TaskResult<[Notice]>)
    
    case dismissAlert
    case displayMessageBar(State.MessageBarType?)
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
        return .send(.fetchNotices(forceReload: false))
        
      case .destination:
        return .none
        
      case .setSortOrder(let order):
        guard let notices = state.notices.elements else {
          return .none
        }
        
        state.noticesSortOrder = order
        
        switch order {
        case .noticeDate:
          guard let orderAscending = state.orderSortType[order] else { return .none }
          let sortedNotices = notices.sorted {
            guard let aDate = $0.date, let bDate = $1.date else { return false }
            let sortOperator: (Date, Date) -> Bool = orderAscending ? (>) : (<)
            return sortOperator(aDate, bDate)
          }
          state.notices = .results(sortedNotices)
          state.orderSortType[order] = !orderAscending
          
        case .createdAtDate:
          guard let orderAscending = state.orderSortType[order] else { return .none }
          let sortedNotices = notices.sorted {
            guard let aCreatedAtDate = $0.createdAt, let bCreateAtDate = $1.createdAt else { return false }
            let sortOperator: (Date, Date) -> Bool = orderAscending ? (>) : (<)
            return sortOperator(aCreatedAtDate, bCreateAtDate)
          }
          state.notices = .results(sortedNotices)
          state.orderSortType[order] = !orderAscending
          
        case .registration:
          guard let orderAscending = state.orderSortType[order] else { return .none }
          let sortedNotices = notices.sorted {
            guard let aRegistration = $0.registration, let bRegistration = $1.registration else { return false }
            let sortOperator: (String, String) -> Bool = orderAscending ? (>) : (<)
            return sortOperator(aRegistration, bRegistration)
          }
          state.notices = .results(sortedNotices)
          state.orderSortType[order] = !orderAscending
          
        case .status:
          guard let orderAscending = state.orderSortType[order] else { return .none }
          let sortedNotices = notices.sorted {
            guard let aStatus = $0.status, let bStatus = $1.status else { return false }
            let sortOperator: (Notice.Status, Notice.Status) -> Bool = orderAscending ? (>) : (<)
            return sortOperator(aStatus, bStatus)
          }
          state.notices = .results(sortedNotices)
          state.orderSortType[order] = !orderAscending
        }
        
        return .run { _ in
          try await fileClient.saveNotices(notices)
        }
        
      case .fetchNotices(let forceReload):
        if let elements = state.notices.elements, !elements.isEmpty, !forceReload {
          return .none
        }
        
        if !forceReload {
          state.notices = .loading
        }
        state.isFetchingNotices = true
        
        return .run { send in
          await send(
            .fetchNoticesResponse(
              TaskResult { try await apiService.getNotices(forceReload) }
            )
          )
        }
        
      case let .fetchNoticesResponse(.success(notices)):
        state.isFetchingNotices = false
        state.notices = notices.isEmpty ? .empty(.emptyNotices()) : .results(notices)
        
        guard !notices.isEmpty else  {
          return .none
        }
        
        return .send(.setSortOrder(state.noticesSortOrder))
        
      case let .fetchNoticesResponse(.failure(error)):
        state.isFetchingNotices = false
        
        if let apiError = error as? ApiError {
          if apiError == .tokenUnavailable {
            state.notices = .error(.tokenUnavailable)
            return .none
          } else {
            state.notices = .error(.loadingError(error: .init(error: apiError)))
          }
        }
        return .none
        
      case .displayMessageBar(let value):
        state.errorBarMessage = value
        return .none
        
      case .onNavigateToAccountSettingsButtonTapped:
        return .none
        
      case .onNoticeItemTapped(let notice):
        state.destination = .edit(EditNoticeDomain.State(notice: notice))
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
        case .editNoticeResponse(.success), .deleteNoticeResponse(.success):
          return .run { send in
            await send(.fetchNotices(forceReload: true))
          }
          
        case .closeButtonTapped:
          return .run { _ in
            await self.dismiss()
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
    .ifLet(\.$destination, action: \.destination) {
      Destination()
    }
  }
}


// MARK: - Helper

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

enum SortAction: CaseIterable {
  case noticeDate
  case status
  case registration
  case createdAtDate
    
  var text: String {
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
  
  var sortOrder: NoticeListDomain.State.NoticeSortOrder {
    switch self {
    case .noticeDate:
      return .noticeDate
    case .status:
      return .status
    case .registration:
      return .registration
    case .createdAtDate:
      return .createdAtDate
    }
  }
}
