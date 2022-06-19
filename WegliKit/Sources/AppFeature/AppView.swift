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
        NoticesView(store: viewStore.notices == .loading ? .placeholder : self.store)
          .redacted(reason: viewStore.notices == .loading ? .placeholder : [])
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

struct WelcomeView: View {
  var body: some View {
    Text("Welcome to weg-li")
      .font(.largeTitle)
    Text("📸 📝 ✊")
      .font(/*@START_MENU_TOKEN@*/ .title/*@END_MENU_TOKEN@*/)
  }
}

extension UIDevice {
  static var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
  }
  
  static var isIPhone: Bool {
    UIDevice.current.userInterfaceIdiom == .phone
  }
}

extension Notice {
  var displayColor: String? {
    guard let safeColor = color else { return nil }
    return DescriptionState.colors.first { color in
      color.key.lowercased() == safeColor.lowercased()
    }?.value
  }
}

public struct NoticesView: View {
  let store: Store<AppState, AppAction>
  @ObservedObject var viewStore: ViewStore<AppState, AppAction>
  
  public init(store: Store<AppState, AppAction>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  public var body: some View {
    Group {
      switch viewStore.notices {
      case .loading:
        ActivityIndicator(style: .medium, color: .gray)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      case let .results(notices):
        List(notices) { notice in
          NoticeView(notice: notice)
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
      case .empty:
        emptyStateView
          .padding(.horizontal)
      case let .error(errorState):
        VStack(alignment: .center, spacing: .grid(2)) {
          if let systemImageName = errorState.systemImageName {
            Image(systemName: systemImageName)
              .font(.title)
              .padding(.bottom, .grid(3))
          }
          
          Text(errorState.title)
            .font(.title2.weight(.semibold))
            .padding(.bottom, .grid(2))
          
          if let body = errorState.body {
            Text(body)
              .font(.body)
              .multilineTextAlignment(.center)
          }
          
          if let errorMessage = errorState.error?.errorDump {
            Text(errorMessage)
              .font(.body.italic())
              .multilineTextAlignment(.center)
          }
        }
        .padding(.horizontal, .grid(3))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      }
    }
  }
  
  private var emptyStateView: some View {
    VStack(alignment: .center, spacing: .grid(3)) {
      Image(systemName: "doc.richtext")
        .font(Font.system(.largeTitle))
        .accessibility(hidden: true)
      Text(L10n.Home.emptyStateCopy)
        .font(.system(.title))
        .multilineTextAlignment(.center)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
