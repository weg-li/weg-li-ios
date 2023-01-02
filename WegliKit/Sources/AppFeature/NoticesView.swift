import ComposableArchitecture
import Foundation
import Helper
import L10n
import ReportFeature
import Styleguide
import SwiftUI
import SwiftUINavigation

public struct NoticesView: View {
  public typealias S = AppDomain.State
  public typealias A = AppDomain.Action
  
  let store: Store<S, A>
  @ObservedObject var viewStore: ViewStore<S, A>
  
  public init(store: Store<S, A>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  public var body: some View {
    Group {
      switch viewStore.notices {
      case .loading:
        ProgressView {
          Text("Loading ...")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        
      case let .results(notices):
        List(notices) { notice in
          NoticeView(notice: notice)
            .onTapGesture { viewStore.send(.setNavigationDestination(.edit(notice))) }
            .listRowSeparator(.hidden)
            .sheet(
              unwrapping: viewStore.binding(
                get: \.destination,
                send: { A.setNavigationDestination($0) }
              ),
              case: /S.Destination.edit
            ) { $model in
              NavigationStack {
                EditNoticeView(
                  store: .init(
                    initialState: .init(notice: model),
                    reducer: EditNoticeDomain()
                  )
                )
                .toolbar {
                  ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Button.close) {
                      viewStore.send(.setNavigationDestination(nil))
                    }
                  }
                  ToolbarItem(placement: .confirmationAction) {
                    if viewStore.state.isSendingEditedNotice {
                      ProgressView()
                    } else {
                      Button("Speichern") {
                        viewStore.send(.onSaveNoticeButtonTapped)
                      }
                    }
                  }
                }
              }
            }
        }
        .listStyle(.plain)
        
      case let .empty(emptyState):
        emptyStateView(emptyState)
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
  
  @ViewBuilder
  private func emptyStateView(_ emptyState: EmptyState<AppDomain.Action>) -> some View {
    VStack(alignment: .center, spacing: .grid(3)) {
      Image(systemName: "doc.richtext")
        .font(Font.system(.largeTitle))
        .accessibility(hidden: true)
      Text(emptyState.text)
        .font(.system(.title))
        .multilineTextAlignment(.center)
      if let message = emptyState.message {
        Text(AttributedString(message))
          .font(.body)
          .multilineTextAlignment(.center)
      }
      if let action = emptyState.action {
        Button(
          action: { viewStore.send(action.action) },
          label: { Text(action.label) }
        )
        .buttonStyle(CTAButtonStyle())
        .padding(.top, .grid(3))
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
