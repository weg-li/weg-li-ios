import ApiClient
import Combine
import ComposableArchitecture
import ComposableCoreLocation
import ContactFeature
import FileClient
import ImagesFeature
import KeychainClient
import MessageUI
import NoticeListFeature
import PathMonitorClient
import ReportFeature
import SharedModels
import XCTest

public extension UUID {
  static let reportId = Self(uuidString: "deadbeef-dead-beef-dead-beefdeadbeef")!
}

@MainActor
final class NoticeListFeatureTests: XCTestCase {
  let fixedUUID = { UUID.reportId }
  let fixedDate = { Date(timeIntervalSinceReferenceDate: 0) }
  let scheduler = DispatchQueue.immediate.eraseToAnyScheduler()
  
  func test_ActionFetchNoticeResponse_shouldNotStoreNoticeToFileClientWhenResponseIsEmpty() async {
    let didSaveNotices = ActorIsolated(false)
    
    var fileClient = FileClient.noop
    fileClient.save = { @Sendable _, _ in
      await didSaveNotices.setValue(true)
      return ()
    }
    
    let store = TestStore(
      initialState: .init(notices: .loading),
      reducer: NoticeListDomain(),
      prepareDependencies: { dependencies in
        dependencies.continuousClock = ImmediateClock()
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
  
  func test_Action_onAppear_shouldFetchNoticesWhenTokenisAdded() async {
    let store = TestStore(
      initialState: .init(notices: .loading),
      reducer: NoticeListDomain()
    )
    store.exhaustivity = .off
    store.dependencies.keychainClient = .noop
    store.dependencies.continuousClock = ImmediateClock()
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
      $0.isFetchingNotices = false
      $0.notices = .results([.mock])
    }
    await store.receive(.setSortOrder(.noticeDate)) {
      $0.orderSortType[.noticeDate] = false
    }
  }
  
  func test_Action_onAppear_shouldPresentNoTokenErrorState() async {
    let store = TestStore(
      initialState: .init(notices: .loading),
      reducer: NoticeListDomain()
    )
    store.dependencies.pathMonitorClient = .satisfied
    store.dependencies.keychainClient.getToken = { nil }
    store.dependencies.apiService.getNotices = { _ in
      throw ApiError.tokenUnavailable
    }
    store.dependencies.continuousClock = TestClock()
    
    await store.send(.onAppear)
    await store.receive(.fetchNotices(forceReload: false)) {
      $0.isFetchingNotices = true
    }
    await store.receive(.fetchNoticesResponse(.failure(ApiError.tokenUnavailable))) {
      $0.isFetchingNotices = false
      $0.notices = .error(.tokenUnavailable)
    }
  }
  
  func test_Action_fetchNotices_shouldNotReload_whenElementsHaveBeenLoaded_andNoForceReload() async {
    let store = TestStore(
      initialState: NoticeListDomain.State(notices: .results([.mock])),
      reducer: NoticeListDomain()
    )
    
    await store.send(.fetchNotices(forceReload: false))
    // does not fetch notices again
  }
  
  func test_Action_fetchNotices_shouldReload_whenElementsHaveBeenLoaded_andForceReload() async {
    let testClock = TestClock()
    
    let store = TestStore(
      initialState: NoticeListDomain.State(notices: .results([.mock])),
      reducer: NoticeListDomain()
    )
    store.dependencies.apiService.getNotices = { _ in [.mock] }
    store.dependencies.fileClient.save = { @Sendable _, _ in () }
    store.dependencies.continuousClock = testClock
    
    await store.send(.fetchNotices(forceReload: true)) {
      $0.notices = .loading
      $0.isFetchingNotices = true
    }
    await store.receive(.fetchNoticesResponse(.success([.mock]))) {
      $0.isFetchingNotices = false
      $0.notices = .results([.mock])
    }
    await store.receive(.setSortOrder(.noticeDate)) {
      $0.notices = .results([.mock])
      $0.orderSortType[.noticeDate] = false
    }
  }
  
  func test_Action_setNoticesSortOrder() async {
    let didSaveNotices = ActorIsolated(false)
    let state = NoticeListDomain.State(notices: .results([.xxxx123, .xxxy123, .abcd123]))
    
    let store = TestStore(
      initialState: state,
      reducer: NoticeListDomain()
    )
    store.dependencies.fileClient.save = { @Sendable _, _ in
      await didSaveNotices.setValue(true)
      return ()
    }
    
    var order: NoticeListDomain.State.NoticeSortOrder = .registration
    await store.send(.setSortOrder(order)) {
      $0.noticesSortOrder = order
      $0.orderSortType[order] = true
      $0.notices = .results([.abcd123, .xxxx123, .xxxy123])
    }
    await didSaveNotices.withValue { value in
      XCTAssertTrue(value)
    }
    await store.send(.setSortOrder(order)) {
      $0.orderSortType[order] = false
      $0.notices = .results([.xxxy123, .xxxx123, .abcd123])
    }

    order = .createdAtDate
    await store.send(.setSortOrder(order)) {
      $0.noticesSortOrder = order
      $0.orderSortType[order] = true
      $0.notices = .results([.xxxy123, .xxxx123, .abcd123])
    }
    await store.send(.setSortOrder(order)) {
      $0.orderSortType[order] = false
      $0.notices = .results([.abcd123, .xxxx123, .xxxy123])
    }

    order = .noticeDate
    await store.send(.setSortOrder(order)) {
      $0.noticesSortOrder = order
      $0.orderSortType[order] = false
      $0.notices = .results([.abcd123, .xxxy123, .xxxx123])
    }
    await store.send(.setSortOrder(order)) {
      $0.orderSortType[order] = true
      $0.notices = .results([.xxxx123, .xxxy123, .abcd123])
    }

    order = .status
    await store.send(.setSortOrder(order)) {
      $0.noticesSortOrder = order
      $0.orderSortType[order] = true
      $0.notices = .results([.xxxy123, .abcd123, .xxxx123])
    }
    await store.send(.setSortOrder(order)) {
      $0.orderSortType[order] = false
      $0.notices = .results([.xxxx123, .xxxy123, .abcd123])
    }
  }
}


// MARK: - Helper

extension SharedModels.Notice {
  static let xxxy123 = Self(
    token: "xxxy123",
    status: .open,
    street: "xxxy123+Street",
    city: "xxxy123+City",
    zip: "xxxy123+Zip",
    latitude: 0,
    longitude: 0,
    registration: "xxxy123",
    brand: "Audi",
    color: "blue",
    charge: .init(tbnr: "CHARGE"),
    date: Date(timeIntervalSince1970: 1_380_624_207),
    duration: 1,
    severity: nil,
    note: "NOTE",
    createdAt: Date(timeIntervalSince1970: 1_580_624_207),
    updatedAt: Date(timeIntervalSince1970: 1_580_624_207),
    sentAt: Date(timeIntervalSince1970: 1_580_624_207),
    photos: []
  )
  
  static let xxxx123 = Self(
    token: "xxxx123",
    status: .disabled,
    street: "xxxx123+Street",
    city: "xxxx123+City",
    zip: "xxxx123+Zip",
    latitude: 0,
    longitude: 0,
    registration: "xxxx123",
    brand: "Opel",
    color: "orange",
    charge: .init(tbnr: "CHARGE"),
    date: Date(timeIntervalSince1970: 1_299_624_207),
    duration: 1,
    severity: nil,
    note: "NOTE",
    createdAt: Date(timeIntervalSince1970: 1_599_624_207),
    updatedAt: Date(timeIntervalSince1970: 1_599_624_207),
    sentAt: Date(timeIntervalSince1970: 1_599_624_207),
    photos: []
  )
  
  static let abcd123 = Self(
    token: "abcd123",
    status: .open,
    street: "abcd123+Street",
    city: "abcd123+City",
    zip: "abcd123+Zip",
    latitude: 0,
    longitude: 0,
    registration: "abcd123",
    brand: "VW",
    color: "black",
    charge: .init(tbnr: "CHARGE"),
    date: Date(timeIntervalSince1970: 1_499_624_207),
    duration: 1,
    severity: nil,
    note: "NOTE",
    createdAt: Date(timeIntervalSince1970: 1_899_624_207),
    updatedAt: Date(timeIntervalSince1970: 1_899_624_207),
    sentAt: Date(timeIntervalSince1970: 1_899_624_207),
    photos: []
  )
}

