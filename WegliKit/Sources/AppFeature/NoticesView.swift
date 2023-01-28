import ComposableArchitecture
import Foundation
import Helper
import L10n
import ReportFeature
import SharedModels
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
          noticeView(notice)
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
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Menu(
          content: {
            Button(
              action: { viewStore.send(.setSortOrder(.noticeDate)) },
              label: {
                if viewStore.noticesSortOrder == .noticeDate {
                  let isAscending = viewStore.orderSortType[.noticeDate, default: true]
                  Label("Tatzeit", systemImage: isAscending ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                } else {
                  Text("Tatzeit")
                }
              }
            )
            
            Button(
              action: { viewStore.send(.setSortOrder(.registration)) },
              label: {
                if viewStore.noticesSortOrder == .registration {
                  let isAscending = viewStore.orderSortType[.registration, default: true]
                  Label("Kennzeichen", systemImage: isAscending ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                } else {
                  Text("Kennzeichen")
                }
              }
            )
            
            Button(
              action: { viewStore.send(.setSortOrder(.createdAtDate)) },
              label: {
                if viewStore.noticesSortOrder == .createdAtDate {
                  let isAscending = viewStore.orderSortType[.createdAtDate, default: true]
                  Label("Erstellt", systemImage: isAscending ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                } else {
                  Text("Erstellt")
                }
              }
            )
            
            Button(
              action: { viewStore.send(.setSortOrder(.status)) },
              label: {
                if viewStore.noticesSortOrder == .status {
                  let isAscending = viewStore.orderSortType[.status, default: true]
                  Label("Status", systemImage: isAscending ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                } else {
                  Text("Status")
                }
              }
            )
          },
          label: {
            Image(systemName: "arrow.up.arrow.down")
              .unredacted()
              .foregroundColor(Color(uiColor: .label))
              .font(.body)
              .frame(width: .grid(8), height: .grid(8))
          }
        )
        .disabled(viewStore.isFetchingNotices)
      }
    }
  }
  
  func noticeView(_ notice: Notice) -> some View {
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
          IfLetStore(
            self.store.scope(
              state: \.editNotice,
              action: A.editNotice
            ),
            then: { store in
              EditNoticeView(store: store)
            },
            else: { Text("Error creating EditNotice view") }
          )
          .accessibilityAddTraits([.isModal])
          .navigationTitle(Text("Meldung bearbeiten"))
          .navigationBarTitleDisplayMode(.inline)
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
