import ComposableArchitecture
import Foundation
import Helper
import L10n
import SharedModels
import Styleguide
import SwiftUI

public struct NoticeListView: View {
  public typealias S = NoticeListDomain.State
  public typealias A = NoticeListDomain.Action
  
  @State private var errorMessage: S.MessageBarType?
  
  let store: StoreOf<NoticeListDomain>
  @ObservedObject var viewStore: ViewStoreOf<NoticeListDomain>
  
  public init(store: StoreOf<NoticeListDomain>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
  }
  
  public var body: some View {
    Group {
      switch viewStore.contentState {
      case .loading:
        noticeList(notices: .placeholder)
          .redacted(reason: viewStore.isFetchingNotices ? .placeholder : [])
          .disabled(viewStore.isFetchingNotices)
        
      case .results(let results):
        noticeList(notices: results.map(\.notice))
        
      case .empty(let emptyState):
        ScrollView {
          Spacer(minLength: 150)
          emptyStateView(emptyState)
            .padding(.horizontal)
        }
        
      case .error(let errorState):
        errorStateView(errorState)
      }
    }
    .onAppear { viewStore.send(.onAppear) }
    .onChange(
      of: viewStore.state.errorBarMessage,
      perform: { newValue in
        withAnimation {
          errorMessage = newValue
        }
      }
    )
    .overlay(alignment: .bottom) {
      messageBarView()
    }
    .sheet(store: self.store.scope(state: \.$selection, action: \.editNotice)) { store in
      editNoticeSheet(store: store)
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Menu(
          content: { menuContent() },
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
  func editNoticeSheet(store: StoreOf<EditNoticeDomain>) -> some View {
    NavigationStack {
      EditNoticeView(store: store)
        .accessibilityAddTraits([.isModal])
        .navigationTitle(Text("Bearbeiten"))
        .navigationBarTitleDisplayMode(.inline)
    }
  }
  
  @ViewBuilder
  func menuContent() -> some View {
    ForEach(SortAction.allCases, id: \.self) { sortAction in
      Button(
        action: {
          viewStore.send(
            .setSortOrder(sortAction, viewStore.noticesSortState.sortType.toggled)
          )
        },
        label: {
          if viewStore.noticesSortState.action == sortAction {
            Label(sortAction.text, systemImage: viewStore.noticesSortState.sortType.isAscending ? "arrow.down" : "arrow.up")
          } else {
            Text(sortAction.text)
          }
        }
      )
      .disabled(viewStore.state.isSortActionDisabled(sortAction))
    }
  }
  
  @ViewBuilder
  func noticeList(notices: [Notice]) -> some View {
    List(notices) { notice in
      NoticeView(notice: notice)
        .onTapGesture { viewStore.send(.onNoticeItemTapped(notice)) }
        .listRowSeparator(.hidden)
    }
    .refreshable {
      await viewStore.send(.fetchNotices(forceReload: true), while: \.isFetchingNotices)
    }
    .listStyle(.plain)
  }
  
  @ViewBuilder
  func messageBarView() -> some View {
    switch errorMessage {
    case .none:
      EmptyView()
    case .some(let wrapped):
      if case let .error(message) = wrapped {
        errorBarMessageView(text: message)
          .transition(.opacity)
          .animation(.easeOut, value: errorMessage != nil)
      } else {
        EmptyView()
      }
    }
  }
  
  @ViewBuilder
  func errorStateView(_ errorState: ErrorState) -> some View {
    ScrollView {
      Spacer(minLength: 150)
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
            .font(.system(.body).monospaced())
            .multilineTextAlignment(.center)
            .lineLimit(10)
        }

        if errorState == .tokenUnavailable {
          goToAccountSettings()
            .padding(.vertical)
        } else {
          Button(
            action: { viewStore.send(.fetchNotices(forceReload: true)) },
            label: {
              Text("Neu laden")
                .padding(.horizontal)
            }
          )
          .buttonStyle(CTAButtonStyle())
          .padding(.vertical)
        }
      }
      .padding(.horizontal, .grid(3))
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
  }
  
  @ViewBuilder
  func errorBarMessageView(text: String) -> some View {
    ZStack {
      Color.red
      
      HStack {
        Image(systemName: "exclamationmark.octagon")
        VStack {
          Text("Error loading notices")
            .bold()
          Text(text)
            .lineLimit(1)
            .font(.system(.body).monospaced())
        }
        .frame(maxWidth: .infinity)
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
      action: { viewStore.send(.onNavigateToAccountSettingsButtonTapped) },
      label: { Text("Zu den Einstellungen").padding(.horizontal) }
    )
    .buttonStyle(CTAButtonStyle())
  }
  
  @ViewBuilder
  func emptyStateView(_ emptyState: EmptyState<NoticeListDomain.Action>) -> some View {
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
        initialState: NoticeListDomain.State(notices: []),
        reducer: { EmptyReducer() }
      )
    )
  }
}


// MARK: Helper

extension Array where Element == Notice {
  static let placeholder: [Element] = [
    .placeholder(),
    .placeholder(),
    .placeholder(),
    .placeholder(),
    .placeholder(),
    .placeholder()
  ]
}
