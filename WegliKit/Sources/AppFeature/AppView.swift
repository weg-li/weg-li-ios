// Created for weg-li in 2021.

import ComposableArchitecture
import L10n
import Helper
import ReportFeature
import SettingsFeature
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
            reportsView()
            
            addReportButton
              .padding(.grid(6))
          }
        } else {
          HStack {
            reportsView()
              .frame(width: 300)
            
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
      .accessibilityAction(.magicTap) {
        viewStore.send(.showReportWizard(true))
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .navigationBarTitle(L10n.Home.navigationBarTitle)
      .navigationBarItems(trailing: contactData)
      .onAppear { viewStore.send(.onAppear) }
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
  
  @ViewBuilder private func reportsView() -> some View {
    if viewStore.reports.isEmpty {
      emptyStateView
        .padding(.horizontal)
    } else {
      ScrollView {
        ForEach(viewStore.reports, id: \.id) { report in
          ReportCellView(report: report)
        }
        .padding()
      }
    }
  }
  
  private var emptyStateView: some View {
    VStack(spacing: 12) {
      Image(systemName: "doc.richtext")
        .font(Font.system(.largeTitle))
        .accessibility(hidden: true)
      Text(L10n.Home.emptyStateCopy)
        .font(.system(.title))
        .multilineTextAlignment(.center)
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
  
  private var contactData: some View {
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
    Preview {
      AppView(
        store: .init(
          initialState: AppState(
            reports: [.preview, .preview, .preview, .preview]
          ),
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
