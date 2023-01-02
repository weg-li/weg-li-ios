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
    var notice: Notice
    
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
      notice: Notice
    ) {
      self.notice = notice
      self.description = .init(model: notice)
      self.licensePlateNumber = notice.registration ?? ""
      self.createdAt = notice.createdAt ?? .now
      self.street = notice.street ?? ""
      self.city = notice.city ?? ""
      self.zip = notice.zip ?? ""
      self.selectedColor = notice.color.flatMap { color -> Int in
        let colors = DescriptionDomain.colors
        guard let index = colors.firstIndex(where: { color == $0.key }) else { return 0 }
        return index
      } ?? 0
    }
  }
  
  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
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
  
  var body: some View {
    List {
      if let photos = viewStore.notice.photos {
        Section {
          ImageGrid {
            ForEach(photos, id: \.self) { photo in
              if let url = URL(string: photo.url) {
                AsyncThumbnailView(url: url)
                  .frame(
                    minWidth: 50,
                    maxWidth: .infinity,
                    minHeight: 100,
                    maxHeight: 100
                  )
                  .clipShape(RoundedRectangle(cornerRadius: 10))
                  .padding(.grid(1))
              }
            }
          }
        } header: {
          SectionHeader(text: L10n.Photos.widgetTitle)
        }
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
    .listStyle(.insetGrouped)
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
