import ComposableArchitecture
import Foundation
import SwiftUI

public struct CarBrandSelection: Reducer {
  public init() {}
  
  public struct State: Equatable {
    public var selectedBrand: CarBrand?
    @BindingState public var carBrandSearchText = ""
    
    public init(selectedBrand: CarBrand? = nil, carBrandSearchText: String = "") {
      self.selectedBrand = selectedBrand
      self.carBrandSearchText = carBrandSearchText
    }
    
    var carBrandSearchResults: IdentifiedArrayOf<CarBrand> {
      if carBrandSearchText.isEmpty {
        return DescriptionDomain.brands
      } else {
        return DescriptionDomain.brands.filter { $0.title.lowercased().contains(carBrandSearchText.lowercased()) }
      }
    }
  }
  
  public enum Action: Equatable, BindableAction {
    case setBrand(CarBrand)
    case binding(BindingAction<State>)
  }
  
  public var body: some ReducerOf<Self> {
    Reduce<State, Action> { state, action in
      switch action {
      case .setBrand(let brand):
        state.selectedBrand = brand
        return .none
      case .binding:
        return .none
      }
    }
    
    BindingReducer()
  }
}

public struct CarBrandSelectorView: View {
  public typealias S = CarBrandSelection.State
  public typealias A = CarBrandSelection.Action
  
  private let store: StoreOf<CarBrandSelection>
  @ObservedObject private var viewStore: ViewStoreOf<CarBrandSelection>
  
  public init(store: StoreOf<CarBrandSelection>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
  }
  
  public var body: some View {
    List {
      ForEach(viewStore.carBrandSearchResults, id: \.id) { brand in
        HStack {
          Text(brand.title)
            .foregroundColor(Color(.label))
            .multilineTextAlignment(.leading)
          Spacer()
          if viewStore.state.selectedBrand == brand {
            Image(systemName: "checkmark")
              .resizable()
              .frame(width: .grid(4), height: .grid(4))
              .foregroundColor(.blue)
          }
        }
        .accessibilityValue(Text(viewStore.state.selectedBrand == brand ? "ausgewählt" : ""))
        .padding(.grid(1))
        .contentShape(Rectangle())
        .onTapGesture {
          viewStore.send(.setBrand(brand))
        }
      }
    }
    .searchable(
      text: viewStore.$carBrandSearchText,
      placement: .navigationBarDrawer(displayMode: .always)
    )
  }
}
