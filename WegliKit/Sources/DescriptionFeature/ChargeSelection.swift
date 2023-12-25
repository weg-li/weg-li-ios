import ComposableArchitecture
import Dependencies
import FeedbackGeneratorClient
import FileClient
import Foundation
import SwiftUI

public struct ChargeSelection: Reducer {
  public init() {}
  
  @Dependency(\.continuousClock) public var clock
  @Dependency(\.fileClient) public var fileClient
  @Dependency(\.feedbackGenerator) public var feedbackGenerator
  
  public struct State: Equatable {
    public var selectedCharge: Charge?
    @BindingState public var chargeTypeSearchText = ""
    
    public init(
      selectedCharge: Charge? = nil,
      chargeTypeSearchText: String = ""
    ) {
      self.selectedCharge = selectedCharge
      self.chargeTypeSearchText = chargeTypeSearchText
    }
    
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
    case onAppear
    case favoriteChargesLoaded(TaskResult<[String]>)
  }
  
  public var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce<State, Action> { state, action in
      switch action {
      case .binding:
        return .none
        
      case .onAppear:
        return .run { send in
          await send(.favoriteChargesLoaded(
            TaskResult {
              try await fileClient.loadFavoriteCharges()
            }
          ))
        }
        
      case let .favoriteChargesLoaded(result):
        let chargeIds = (try? result.value) ?? []
          
        let charges = DescriptionDomain.charges.map {
          Charge(
            id: $0.id,
            text: $0.text,
            isFavorite: chargeIds.contains($0.id),
            isSelected: false
          )
        }
        state.charges = IdentifiedArrayOf(uniqueElements: charges, id: \.id)
        return .send(.sortFavoritedCharges)
        
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
          .run { send in
            try await clock.sleep(for: .seconds(0.4))
            return await send(.sortFavoritedCharges)
          },
          .run { _ in
            await feedbackGenerator.selectionChanged()
          },
          .run(priority: .userInitiated) { _ in
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
  
  private let store: StoreOf<ChargeSelection>
  @ObservedObject private var viewStore: ViewStoreOf<ChargeSelection>
  
  public init(store: StoreOf<ChargeSelection>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
  }
  
  public var body: some View {
    List {
      ForEach(viewStore.chargesSearchResults, id: \.id) { charge in
        ChargeView(
          text: charge.text,
          isSelected: viewStore.selectedCharge?.id == charge.id,
          isFavorite: charge.isFavorite,
          onTap: { viewStore.send(.setCharge(charge), animation: .default) },
          onSwipe: { viewStore.send(.toggleChargeFavorite(charge), animation: .default) }
        )
      }
    }
    .onAppear { viewStore.send(.onAppear) }
    .animation(.default, value: viewStore.chargesSearchResults)
    .searchable(
      text: viewStore.$chargeTypeSearchText,
      placement: .navigationBarDrawer(displayMode: .always)
    )
    .disableAutocorrection(true)
  }
}
