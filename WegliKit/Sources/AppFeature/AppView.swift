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
  
  private let store: StoreOf<AppDomain>
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  
  public init(store: Store<S, A>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(store, observe: \.selectedTab) { viewStore in
      TabView(selection: viewStore.binding(send: { A.viewAction(.setSelectedTab($0)) })) {
        NavigationStack {
          NoticeListView(
            store: store.scope(
              state: \.noticeList,
              action: A.noticeList
            )
          )
          .navigationBarTitle(L10n.Home.navigationBarTitle)
        }
        .tabItem { Label(L10n.notices, systemImage: "list.dash") }
        .tag(Tabs.notices)
        
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
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    Preview {
      AppView(
        store: Store(
          initialState: AppDomain.State(),
          reducer: AppDomain()
        )
      )
    }
  }
}

// MARK: - Helper

extension Notice {
  var displayColor: String? {
    guard let safeColor = color else { return nil }
    return DescriptionDomain.colors.first { color in
      color.key.lowercased() == safeColor.lowercased()
    }?.value
  }
}
