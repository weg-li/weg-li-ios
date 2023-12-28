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
import NoticeListFeature
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

public struct AppDomain: Reducer {
  public init() {}
  
  @Dependency(\.continuousClock) public var clock
  @Dependency(\.fileClient) public var fileClient
  @Dependency(\.keychainClient) public var keychainClient
  @Dependency(\.apiService) public var apiService
  @Dependency(\.uuid) public var uuid
  @Dependency(\.date) public var date
  @Dependency(\.pathMonitorClient) public var pathMonitorClient
  
  public struct State: Equatable {
    public var settings: SettingsDomain.State
    public var contact: Contact = .empty
    public var noticeList: NoticeListDomain.State
    
    public var reportDraft: ReportDomain.State = .init(
      uuid: UUID.init,
      images: .init(),
      contactState: .empty,
      date: Date.init
    )
    
    public var selectedTab: Tabs = .notice
    
    public var isFetchingNotices = false
    
    enum Destination: Equatable {
      case noticeList(NoticeListDomain.Destination?)
      case report(ReportDomain.Destination?)
      case settings(SettingsDomain.Destination?)
    }
  }
  
  public enum Action: Equatable {
    case internalAction(InternalAction)
    case viewAction(ViewAction)

    case settings(SettingsDomain.Action)
    case report(ReportDomain.Action)
    case noticeList(NoticeListDomain.Action)

    case reportSaved
    
    public enum ViewAction: Equatable {
      case setSelectedTab(Tabs)
    }
    public enum InternalAction: Equatable {
      case appDelegate(AppDelegateDomain.Action)
      case contactSettingsLoaded(TaskResult<Contact>)
      case userSettingsLoaded(TaskResult<UserSettings>)
      case storedApiTokenLoaded(TaskResult<String?>)
    }
  }
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.noticeList, action: /Action.noticeList) {
      NoticeListDomain()
    }
    
    Scope(state: \.reportDraft, action: /Action.report) {
      ReportDomain()
    }
    
    Scope(state: \.settings, action: /Action.settings) {
      SettingsDomain()
    }
    
    Reduce<State, Action> { state, action in
      switch action {
      case .internalAction(let internalAction):
        switch internalAction {
        case .appDelegate:
          return .run { send in
            await withThrowingTaskGroup(of: Void.self) { group in
              group.addTask {
                await send(
                  .internalAction(
                    .contactSettingsLoaded(
                      TaskResult { try await fileClient.loadContactSettings() }
                    )
                  )
                )
              }
              group.addTask {
                await send(
                  .internalAction(
                    .userSettingsLoaded(
                      TaskResult { try await fileClient.loadUserSettings() }
                    )
                  )
                )
              }
              group.addTask {
                await send(
                  .internalAction(
                    .storedApiTokenLoaded(
                      TaskResult { await keychainClient.getApiToken() }
                    )
                  )
                )
              }
            }
          }
          
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
        }
        
      case .viewAction(let viewAction):
        switch viewAction {
        case .setSelectedTab(let tab):
          state.selectedTab = tab
          return .none
        }
        
        
      case .settings(let settingsAction):
        switch settingsAction {
        case .userSettings:
          // store usersettings when changed
          state.reportDraft.images.showsAllTextRecognitionResults = state.settings.userSettings.showsAllTextRecognitionSettings
          state.reportDraft.alwaysSendNotice = state.settings.userSettings.alwaysSendNotice
          return .none
                  
        default:
          return .none
        }
        
        // After the emailResult reports the mail has been sent the report will be stored.
      case .report(.mail(.setMailResult(.sent))):
        return .none
        
      case .report(.resetConfirmButtonTapped):
        state.reportDraft = ReportDomain.State(
          uuid: uuid.callAsFunction,
          images: .init(),
          contactState: .init(contact: state.contact),
          date: date.callAsFunction,
          location: .init()
        )
        state.reportDraft.apiToken = keychainClient.getToken() ?? ""
        return .none
        
//      case .report(.contact):
//        state.contact = state.reportDraft.contactState.contact
//        return .none
              
      case .reportSaved:
        // Reset report draft after it was saved
        state.reportDraft = ReportDomain.State(
          uuid: uuid.callAsFunction,
          images: .init(),
          contactState: .init(contact: state.contact),
          date: date.callAsFunction
        )
        return .none
        
      case .noticeList(.onNavigateToAccountSettingsButtonTapped):
        return .concatenate(
          .send(.viewAction(.setSelectedTab(.settings)))
        )
        
      case .noticeList, .report:
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
    noticeList: NoticeListDomain.State = .init(notices: [])
  ) {
    self.settings = settings
    self.noticeList = noticeList
  }
}

