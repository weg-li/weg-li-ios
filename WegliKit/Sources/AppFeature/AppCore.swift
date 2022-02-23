// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import Contacts
import Foundation
import MapKit
import PlacesServiceClient
import ReportFeature
import SettingsFeature
import SharedModels
import UIKit
import UserDefaultsClient

// MARK: - AppState

public struct AppState: Equatable {
  public init(
    settings: SettingsState = SettingsState(contact: .empty),
    reports: [Report] = [],
    showReportWizard: Bool = false
  ) {
    self.settings = settings
    self.reports = reports
    self.showReportWizard = showReportWizard
  }
  
  /// Settings
  public var settings = SettingsState(contact: .empty)
  
  /// Reports a user has sent
  public var reports: [Report] = []
  
  /// Holds a report that has not been stored or sent via mail
  var _storedReport: Report?
  public var reportDraft: Report {
    get {
      guard let report = _storedReport else {
        return Report(images: .init(), contactState: settings.contact, date: Date.init)
      }
      return report
    }
    set {
      _storedReport = newValue
    }
  }
  
  var showReportWizard = false
}

// MARK: - AppAction

public enum AppAction: Equatable {
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
    userDefaultsClient: UserDefaultsClient
  ) {
    self.mainQueue = mainQueue
    self.userDefaultsClient = userDefaultsClient
  }
  
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var userDefaultsClient: UserDefaultsClient
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
          locationManager: .live,
          placeService: .live,
          regulatoryOfficeMapper: .live()
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
      // restore state from userdefaults
    case .onAppear:
      if let contact = environment.userDefaultsClient.contact {
        state.settings = SettingsState(
          contact: .init(
            contact: contact, alert: nil
          )
        )
      }
      state.reports = environment.userDefaultsClient.reports
      return .none
      // After the EditDescriptionView disappeared the contact data needs to be synced with the reportDraft
      // and stored.
    case let .settings(settingsAction):
      switch settingsAction {
      case .contact(.onDisappear):
        state.reportDraft.contactState = state.settings.contact
        return environment.userDefaultsClient.setContact(state.settings.contact.contact)
          .fireAndForget()
      default:
        return .none
      }
    // After the emailResult reports the mail has been sent the report will be stored.
    case let .report(reportAction):
      switch reportAction {
      case let .mail(mailAction):
        switch mailAction {
        case let .setMailResult(result):
          guard let mailComposerResult = result else {
            return .none
          }
          switch mailComposerResult {
          case .sent:
            state.reports.append(state.reportDraft)
            
            state.reportDraft.images.storedPhotos.forEach { image in
              // TODO: remove copied images app dir
            }
            
            return Effect.concatenate(
              environment.userDefaultsClient.setReports(state.reports)
                .fireAndForget(),
              Effect(value: AppAction.reportSaved)
            )
          default:
            return .none
          }
        default:
          return .none
        }
      case .contact:
        // sync contact with draftReport contact
        state.settings.contact = state.reportDraft.contactState
        return .none
      case .resetConfirmButtonTapped:
        state.reportDraft = Report(images: .init(), contactState: state.settings.contact, date: Date.init)
        return .none
      default:
        return .none
      }
    case let .showReportWizard(value):
      state.showReportWizard = value
      return .none
      // Reset report draft after it was .
    case .reportSaved:
//      state.reportDraft = Report(images: .init(), contactState: state.settings.contact, date: Date.init)
      return .none
    }
  }
)


// MARK: Helper
extension AppState {
  static let preview = AppState()
  
  // init for previews
  init(reports: [Report]) {
    self.init()
    self.reports = reports
  }
}

extension UserDefaultsClient {
  public var reports: [Report] {
    (try? dataForKey(reportsKey)?.decoded()) ?? []
  }

  public func setReports(_ reports: [Report]) -> Effect<Never, Never> {
    let data = try? reports.encoded()
    return setData(data, reportsKey)
  }
}

let reportsKey = "reportsKey"
