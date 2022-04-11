// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import Contacts
import FileClient
import Foundation
import MapKit
import PlacesServiceClient
import ReportFeature
import SettingsFeature
import SharedModels
import UIKit

// MARK: - AppState

public struct AppState: Equatable {
  /// Settings
  public var settings: SettingsState
  
  /// Reports a user has sent
  public var reports: [Report]
  
  /// Holds a report that has not been stored or sent via mail
  public var reportDraft: Report = .init(
    uuid: UUID.init,
    images: .init(),
    contactState: .empty,
    date: Date.init
  )
  
  var showReportWizard = false
  
  public init(
    settings: SettingsState = .init(contact: .empty),
    reports: [Report] = [],
    showReportWizard: Bool = false
  ) {
    self.settings = settings
    self.reports = reports
    self.showReportWizard = showReportWizard
  }
  
}

// MARK: - AppAction

public enum AppAction: Equatable {
  case appDelegate(AppDelegateAction)
  case contactSettingsLoaded(Result<Contact, NSError>)
  case storedReportsLoaded(Result<[Report], NSError>)
  case settings(SettingsAction)
  case report(ReportAction)
  case showReportWizard(Bool)
  case reportSaved
  case onAppear
}

// MARK: - Environment

public struct AppEnvironment {
  public init(
    mainQueue: AnySchedulerOf<DispatchQueue>,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    fileClient: FileClient,
    date: @escaping () -> Date = Date.init,
    uuid: @escaping () -> UUID = UUID.init
  ) {
    self.mainQueue = mainQueue
    self.backgroundQueue = backgroundQueue
    self.fileClient = fileClient
    self.date = date
    self.uuid = uuid
  }
  
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var fileClient: FileClient
  
  public var date: () -> Date
  public var uuid: () -> UUID
}

public extension AppEnvironment {
  static let live = Self(
    mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
    backgroundQueue: DispatchQueue(label: "background-queue").eraseToAnyScheduler(),
    fileClient: .live
  )
}

/// Reducer handling actions from the HomeView and combining it with the reducers from descending screens.
public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  reportReducer
    .pullback(
      state: \.reportDraft,
      action: /AppAction.report,
      environment: { environment in
        ReportEnvironment(
          mainQueue: environment.mainQueue,
          backgroundQueue: environment.backgroundQueue,
          locationManager: .live,
          placeService: .live,
          regulatoryOfficeMapper: .live(),
          fileClient: environment.fileClient
        )
      }
    ),
  settingsReducer.pullback(
    state: \.settings,
    action: /AppAction.settings,
    environment: { _ in SettingsEnvironment(uiApplicationClient: .live) }
  ),
  Reducer { state, action, environment in
    switch action {
    case let .appDelegate(appDelegateAction):
      return .merge(
        .concatenate(
          environment.fileClient.loadContactSettings()
            .map(AppAction.contactSettingsLoaded),
          environment.fileClient.loadReports()
            .map(AppAction.storedReportsLoaded)
        )
      )
      
    case let .contactSettingsLoaded(result):
      let contact = (try? result.get()) ?? .init()
      state.settings = SettingsState(
        contact: .init(contact: contact, alert: nil)
      )
      return .none
      
    case let .storedReportsLoaded(result):
      let reports = (try? result.get()) ?? []
      state.reports = reports
      return .none
      
    case .onAppear:
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
      state.reports.append(state.reportDraft)

      state.showReportWizard = false
      
      return Effect.merge(
        environment.fileClient
          .saveReports(state.reports, on: environment.backgroundQueue)
          .fireAndForget(),
        Effect(value: AppAction.reportSaved)
      )
      
    case .report(.resetConfirmButtonTapped):
      state.reportDraft = Report(
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
        state.reportDraft = .init(
          uuid: environment.uuid,
          images: .init(),
          contactState: state.settings.contact,
          date: environment.date
        )
      }
      state.showReportWizard = value
      return .none
      
    case .reportSaved:
      // Reset report draft after it was saved
      state.reportDraft = Report(
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


// MARK: Helper
extension AppState {
  static let preview = AppState()
  
  // init for previews
  init(reports: [Report]) {
    self.init()
    self.reports = reports
  }
}
