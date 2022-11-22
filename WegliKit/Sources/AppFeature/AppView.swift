// Created for weg-li in 2021.

import ComposableArchitecture
import DescriptionFeature
import Helper
import L10n
import ReportFeature
import SettingsFeature
import SharedModels
import Styleguide
import SwiftUI

public struct AppView: View {
  private let store: Store<AppState, AppAction>
  @ObservedObject private var viewStore: ViewStore<AppState, AppAction>
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  
  public init(store: Store<AppState, AppAction>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  public var body: some View {
    TabView(selection: viewStore.binding(\.$selectedTab)) {
      // Notices
      NavigationView {
        NoticesView(store: viewStore.isFetchingNotices ? .placeholder : self.store)
          .redacted(reason: viewStore.isFetchingNotices ? .placeholder : [])
          .refreshable {
            await viewStore.send(.fetchNotices(forceReload: true), while: \.isFetchingNotices)
          }
          .navigationBarTitle(L10n.Home.navigationBarTitle)
          .onAppear { viewStore.send(.onAppear) }
      }
      .tabItem { Label(L10n.notices, systemImage: "list.dash") }
      .tag(Tabs.notices)
      
      // New Notice
      NavigationView {
        ReportView(
          store: store.scope(
            state: \.reportDraft,
            action: AppAction.report
          )
        )
      }
      .tabItem { Label(L10n.Notice.add, systemImage: "plus.circle") }
      .tag(Tabs.notice)
      
      // Settings
      NavigationView {
        SettingsView(
          store: store.scope(
            state: \.settings,
            action: AppAction.settings
          )
        )
      }
      .tabItem { Label(L10n.Settings.title, systemImage: "gearshape") }
      .tag(Tabs.settings)
    }
    .alert(store.scope(state: \.alert), dismiss: .dismissAlert)
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    var appState = AppState()
    appState.notices = .results(.placeholder)
    
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

extension Notice {
  var displayColor: String? {
    guard let safeColor = color else { return nil }
    return DescriptionDomain.State.colors.first { color in
      color.key.lowercased() == safeColor.lowercased()
    }?.value
  }
}
