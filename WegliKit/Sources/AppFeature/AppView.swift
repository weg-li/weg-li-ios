// Created for weg-li in 2021.

import ComposableArchitecture
import DescriptionFeature
import L10n
import Helper
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
    viewStore = ViewStore(store)
  }
  
  public var body: some View {
    NavigationView {
      Group {
        if horizontalSizeClass == .compact {
          ZStack(alignment: .bottomTrailing) {
            NoticesView(store: viewStore.notices == .loading ? .placeholder : self.store)
              .redacted(reason: viewStore.notices == .loading ? .placeholder : [])
            
            addReportButton
              .padding(.grid(6))
          }
        } else {
          HStack {
            NoticesView(store: viewStore.notices == .loading ? .placeholder : self.store)
              .frame(width: 300)
              .redacted(reason: viewStore.notices == .loading ? .placeholder : [])
            
            Divider()
            
            ReportView(
              store: store.scope(
                state: \.reportDraft,
                action: AppAction.report
              )
            )
          }
        }
      }
      .refreshable {
        await viewStore.send(.fetchNotices, while: \.isFetchingNotices)
      }
      .accessibilityAction(.magicTap) {
        viewStore.send(.showReportWizard(true))
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .navigationBarTitle(L10n.Home.navigationBarTitle)
      .navigationBarItems(trailing: settings)
      .onAppear { viewStore.send(.onAppear) }
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
  
  private var addReportButton: some View {
    VStack {
      NavigationLink(
        destination: ReportView(
          store: store.scope(
            state: \.reportDraft,
            action: AppAction.report
          )
        ),
        isActive: viewStore.binding(
          get: \.showReportWizard,
          send: AppAction.showReportWizard
        ),
        label: {
          EmptyView()
        }
      )
      Button(
        action: { viewStore.send(.showReportWizard(true)) },
        label: {
          Image(systemName: "plus").font(.title)
        }
      )
      
      .buttonStyle(AddReportButtonStyle())
      .accessibility(label: Text(L10n.Home.A11y.addReportButtonLabel))
    }
  }
  
  var settings: some View {
    NavigationLink(
      destination: SettingsView(
        store: store.scope(
          state: \.settings,
          action: AppAction.settings
        )
      ),
      label: {
        Image(systemName: "gearshape")
          .font(Font.system(.body).bold())
          .contentShape(Rectangle())
      }
    )
    .accessibility(label: Text(L10n.Settings.title))
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
    guard let safeColor = self.color else { return nil }
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
