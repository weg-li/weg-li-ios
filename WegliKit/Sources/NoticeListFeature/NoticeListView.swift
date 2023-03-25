import ComposableArchitecture
import Foundation
import Helper
import L10n
import SharedModels
import Styleguide
import SwiftUI
import SwiftUINavigation

public struct NoticeListView: View {
  public typealias S = NoticeListDomain.State
  public typealias A = NoticeListDomain.Action
  
  @State private var showErrorBar = false
  
  let store: StoreOf<NoticeListDomain>
  @ObservedObject var viewStore: ViewStoreOf<NoticeListDomain>
  
  public init(store: StoreOf<NoticeListDomain>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
  }
  
  public var body: some View {
    Group {
      switch viewStore.notices {
      case .loading:
        noticeList(notices: .placeholder)
          .redacted(reason: viewStore.isFetchingNotices ? .placeholder : [])
          .disabled(viewStore.isFetchingNotices)
        
      case let .results(notices):
        noticeList(notices: notices)
        
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
          
          if errorState == ErrorState.tokenUnavailable {
            goToAccountSettings()
              .padding(.vertical)
          }
        }
        .padding(.horizontal, .grid(3))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      }
    }
    .onChange(of: viewStore.state.errorBarMessage, perform: { newValue in
      withAnimation {
        showErrorBar = newValue != nil
      }
    })
    .overlay(alignment: .bottom, content: {
      if showErrorBar {
        errorBarMessageView()
          .transition(.opacity)
          .animation(.easeOut, value: showErrorBar)
      }
    })
    .onAppear { viewStore.send(.onAppear) }
    .sheet(
      unwrapping: viewStore.binding(
        get: \.destination,
        send: A.setNavigationDestination
      ),
      case: /S.Destination.edit,
      onDismiss: { viewStore.send(.setNavigationDestination(nil)) }
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
        .navigationTitle(Text("Bearbeiten"))
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
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Menu(
          content: {
            Button(
              action: { viewStore.send(.setSortOrder(.noticeDate)) },
              label: {
                if viewStore.noticesSortOrder == .noticeDate {
                  let isAscending = viewStore.orderSortType[.noticeDate, default: true]
                  Label("Tatzeit", systemImage: isAscending ? "arrowtriangle.down" : "arrowtriangle.up")
                } else {
                  Text("Tatzeit")
                }
              }
            )
            .disabled(!viewStore.showNoticeDateSortOption)
            
            Button(
              action: { viewStore.send(.setSortOrder(.registration)) },
              label: {
                if viewStore.noticesSortOrder == .registration {
                  let isAscending = viewStore.orderSortType[.registration, default: true]
                  Label("Kennzeichen", systemImage: isAscending ? "arrowtriangle.down" : "arrowtriangle.up")
                } else {
                  Text("Kennzeichen")
                }
              }
            )
            .disabled(!viewStore.showRegistrationSortOption)
            
            Button(
              action: { viewStore.send(.setSortOrder(.createdAtDate)) },
              label: {
                if viewStore.noticesSortOrder == .createdAtDate {
                  let isAscending = viewStore.orderSortType[.createdAtDate, default: true]
                  Label("Erstellt", systemImage: isAscending ? "arrowtriangle.down" : "arrowtriangle.up")
                } else {
                  Text("Erstellt")
                }
              }
            )
            .disabled(!viewStore.showCreatedAtDateSortOption)
            
            Button(
              action: { viewStore.send(.setSortOrder(.status)) },
              label: {
                if viewStore.noticesSortOrder == .status {
                  let isAscending = viewStore.orderSortType[.status, default: true]
                  Label("Status", systemImage: isAscending ? "arrowtriangle.down" : "arrowtriangle.up")
                } else {
                  Text("Status")
                }
              }
            )
            .disabled(!viewStore.showStatusSortOption)
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
  
  @ViewBuilder
  func noticeList(notices: [Notice]) -> some View {
    List(notices) { notice in
      NoticeView(notice: notice)
        .onTapGesture { viewStore.send(.setNavigationDestination(.edit(notice))) }
        .listRowSeparator(.hidden)
    }
    .refreshable {
      await viewStore.send(.fetchNotices(forceReload: true), while: \.isFetchingNotices)
    }
    .listStyle(.plain)
  }
  
  @ViewBuilder
  func errorBarMessageView() -> some View {
    ZStack {
      Color.red
      
      HStack {
        Image(systemName: "exclamationmark.octagon")
        Text("Error loading notices")
      }
      .foregroundColor(.white)
      .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: 60)
    .cornerRadius(12)
    .padding()
  }
  
  @ViewBuilder
  func goToAccountSettings() -> some View {
    Button(
      action: { viewStore.send(.onNavigateToAccontSettingsButtonTapped) },
      label: { Text("Zu den Einstellungen") }
    )
    .buttonStyle(CTAButtonStyle())
  }
  
  @ViewBuilder
  private func emptyStateView(_ emptyState: EmptyState<NoticeListDomain.Action>) -> some View {
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

struct NoticeListView_Previews: PreviewProvider {
  static var previews: some View {
    NoticeListView(
      store: .init(
        initialState: NoticeListDomain.State(notices: .results([.mock, .mock])),
        reducer: EmptyReducer()
      )
    )
  }
}


// MARK: Helper

extension Array where Element == Notice {
  static let placeholder: [Element] = Array(repeating: .preview, count: 6)
}
