import ComposableArchitecture
import DescriptionFeature
import Helper
import ImagesFeature
import L10n
import LocationFeature
import ReportFeature
import SharedModels
import Styleguide
import SwiftUI
import SwiftUINavigation

public struct EditNoticeDomain: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var description: DescriptionDomain.State
    
    @BindableState public var createdAt: Date
    
    @BindableState public var selectedColor: Int
    @BindableState public var licensePlateNumber: String
    @BindableState public var street: String
    @BindableState public var city: String
    @BindableState public var zip: String
    
    @BindableState public var presentChargeSelection = false
    @BindableState public var presentCarBrandSelection = false
    
    public var destination: Destination?
    public enum Destination: Equatable {
      case selectBrand(CarBrandSelection.State)
    }
        
    init(
      description: DescriptionDomain.State,
      selectedColor: Int,
      licensePlateNumber: String,
      createdAt: Date,
      street: String,
      city: String,
      zip: String
    ) {
      self.description = description
      self.licensePlateNumber = licensePlateNumber
      self.createdAt = createdAt
      self.street = street
      self.city = city
      self.zip = zip
      self.selectedColor = selectedColor
    }
  }
  
  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<EditNoticeDomain.State>)
    case description(DescriptionDomain.Action)
    case setDestination(State.Destination?)
  }
  
  public var body: some ReducerProtocol<State, Action> {
    Scope(state: \.description, action: /Action.description) {
      DescriptionDomain()
    }
    
    BindingReducer()
    
    Reduce<State, Action> { state, action in
      switch action {
      case .binding:
        return .none
        
      case .description(.chargeSelection(.setCharge)):
        state.description.presentChargeSelection = false
        return .none
      case .description(.carBrandSelection(.setBrand)):
        state.presentCarBrandSelection = false
        return .none
        
      case .description, .setDestination:
        return .none
      }
    }
  }
}


struct EditNoticeView: View {
  public typealias S = EditNoticeDomain.State
  public typealias A = EditNoticeDomain.Action
  
  private let store: Store<S, A>
  @ObservedObject private var viewStore: ViewStore<S, A>
  
  public init(store: Store<S, A>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }
  
  let gridItemLayout = [
    GridItem(.flexible(minimum: 50, maximum: .infinity)),
    GridItem(.flexible(minimum: 50, maximum: .infinity)),
    GridItem(.flexible(minimum: 50, maximum: .infinity))
  ]
  
  var body: some View {
    Group {
      Section {
        ImageGrid {
          ForEach(0..<4, id: \.self) { _ in
            Color.red
          }
        }
      } header: {
        SectionHeader(text: L10n.Photos.widgetTitle)
      }
      
      Section {
        VStack(alignment: .leading) {
          TextField(
            L10n.Location.Placeholder.street,
            text: viewStore.binding(\.$street)
          )
          TextField(
            L10n.Location.Placeholder.city,
            text: viewStore.binding(\.$city)
          )
          TextField(
            L10n.Location.Placeholder.postalCode,
            text: viewStore.binding(\.$zip)
          )
        }
      } header: {
        SectionHeader(text: "Adresse")
      }
      
      Section {
        DatePicker(
          L10n.date,
          selection: viewStore.binding(\.$createdAt)
        )
        .labelsHidden()
      } header: {
        SectionHeader(text: "Datum")
      }
        
      EditDescriptionView(
        store: self.store.scope(
          state: \.description,
          action: A.description
        )
      )
    }
    .textFieldStyle(.roundedBorder)
  }
}

struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    EditNoticeView(
      store: .init(
        initialState: EditNoticeDomain.State(notice: .mock),
        reducer: EditNoticeDomain()
      )
    )
  }
}


extension EditNoticeDomain.State {
  init(notice: Notice) {
    self.createdAt = notice.createdAt ?? .now
    self.street = notice.street ?? ""
    self.city = notice.city ?? ""
    self.zip = notice.zip ?? ""
    self.description = .init(model: notice)
    self.licensePlateNumber = notice.registration ?? ""
    self.selectedColor = notice.color.flatMap { color -> Int in
      let colors = DescriptionDomain.colors
      guard let index = colors.firstIndex(where: { color == $0.key }) else { return 0 }
      return index
    } ?? 0
  }
}
