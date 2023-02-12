// Created for weg-li in 2021.

import ComposableArchitecture
import DescriptionFeature
import Helper
import L10n
import NoticeListFeature
import ReportFeature
import SettingsFeature
import SharedModels
import Styleguide
import SwiftUI

public struct AppView: View {
  public typealias S = AppDomain.State
  public typealias A = AppDomain.Action
  
  private let store: Store<S, A>
  @ObservedObject private var viewStore: ViewStore<S, A>
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  
  public init(store: Store<S, A>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  public var body: some View {
    TabView(selection: viewStore.binding(\.$selectedTab)) {
      // Notices
      NavigationStack {
        NoticeListView(store: viewStore.noticeList.isFetchingNotices ? .placeholder : self.store.scope(state: \.noticeList, action: A.noticeList))
          .redacted(reason: viewStore.noticeList.isFetchingNotices ? .placeholder : [])
          .navigationBarTitle(L10n.Home.navigationBarTitle)
      }
      .tabItem { Label(L10n.notices, systemImage: "list.dash") }
      .tag(Tabs.notices)
      
      // New Notice
      NavigationStack {
        ReportView(
          store: store.scope(
            state: \.reportDraft,
            action: A.report
          )
        )
      }
      .tabItem { Label(L10n.Notice.add, systemImage: "plus.circle") }
      .tag(Tabs.notice)
      
      // Settings
      NavigationStack {
        SettingsView(
          store: store.scope(
            state: \.settings,
            action: A.settings
          )
        )
      }
      .tabItem { Label(L10n.Settings.title, systemImage: "gearshape") }
      .tag(Tabs.settings)
    }
    .navigationViewStyle(.stack)
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    var appState = AppDomain.State()
    appState.noticeList.notices = .results(.placeholder)
    
    return Preview {
      AppView(
        store: .init(
          initialState: appState,
          reducer: .empty,
          environment: ()
        )
      )
    }
  }
}

// MARK: - Helper

public extension Array where Element == Notice {
  static let placeholder: [Element] = Array(repeating: .preview, count: 6)
}

extension Store where State == NoticeListDomain.State, Action == NoticeListDomain.Action {
  static let placeholder = Store(
    initialState: .init(
      notices: .results(.placeholder)
    ),
    reducer: .empty,
    environment: ()
  )
}

extension Notice {
  var displayColor: String? {
    guard let safeColor = color else { return nil }
    return DescriptionDomain.colors.first { color in
      color.key.lowercased() == safeColor.lowercased()
    }?.value
  }
}
