import ComposableArchitecture
import Dependencies
import Foundation
import SwiftUI

public struct ChargeSelection: ReducerProtocol {
  public init() {}
  
  @Dependency(\.continuousClock) public var clock
  @Dependency(\.fileClient) public var fileClient
  
  public struct State: Equatable {
    public var selectedCharge: Charge?
    @BindableState public var chargeTypeSearchText = ""
    
    public var charges: IdentifiedArrayOf<Charge> = []
    var chargesSearchResults: IdentifiedArrayOf<Charge> {
      if chargeTypeSearchText.isEmpty {
        return charges
      } else {
        return charges.filter { $0.text.lowercased().contains(chargeTypeSearchText.lowercased()) }
      }
    }
  }
  
  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case setCharge(Charge)
    case setChargeTypeSearchText(String)
    case toggleChargeFavorite(Charge)
    case sortFavoritedCharges
  }
  
  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    
    Reduce<State, Action> { state, action in
      switch action {
      case .binding:
        return .none
        
      case let .setCharge(value):
        state.selectedCharge = value
        return .none
          
      case let .setChargeTypeSearchText(query):
        state.chargeTypeSearchText = query
        return .none
          
      case let .toggleChargeFavorite(charge):
        var charge = charge
        charge.isFavorite.toggle()
        charge.isSelected = charge.id == state.selectedCharge?.id
        guard let index = state.charges.firstIndex(where: { $0.id == charge.id }) else {
          return .none
        }
        state.charges.update(charge, at: index)
          
        let ids = state.charges
          .filter(\.isFavorite)
          .map(\.id)
        
        return .concatenate(
          .task {
            try await clock.sleep(for: .seconds(0.5))
            return .sortFavoritedCharges
          },
          .fireAndForget(priority: .userInitiated) {
            try await fileClient.saveFavoriteCharges(ids)
          }
        )
          
      case .sortFavoritedCharges:
        state.charges.sort { $0.isFavorite && !$1.isFavorite }
        return .none
      }
    }
  }
}

public struct ChargeSelectionView: View {
  public typealias S = ChargeSelection.State
  public typealias A = ChargeSelection.Action
  
  let store: Store<S, A>
  @ObservedObject private var viewStore: ViewStore<S, A>
  
  public init(store: Store<S, A>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  public var body: some View {
    List {
      ForEach(viewStore.chargesSearchResults, id: \.id) { charge in
        ChargeView(
          text: charge.text,
          isSelected: viewStore.selectedCharge?.id == charge.id,
          isFavorite: charge.isFavorite,
          onTap: { viewStore.send(.setCharge(charge)) },
          onSwipe: { viewStore.send(.toggleChargeFavorite(charge)) }
        )
      }
    }
    .animation(.default, value: viewStore.chargesSearchResults)
    .searchable(
      text: viewStore.binding(\.$chargeTypeSearchText),
      placement: .navigationBarDrawer(displayMode: .always)
    )
    .disableAutocorrection(true)
  }
}
