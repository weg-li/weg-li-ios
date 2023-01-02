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

public struct EditNoticeDomain: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var description: DescriptionDomain.State
    
    @BindableState public var createdAt: Date
    
    @BindableState public var street: String
    @BindableState public var city: String
    @BindableState public var zip: String
    
    init(
      description: DescriptionDomain.State,
      createdAt: Date,
      street: String,
      city: String,
      zip: String
    ) {
      self.description = description
      self.createdAt = createdAt
      self.street = street
      self.city = city
      self.zip = zip
    }
//    init(
//      registration: String,
//      brand: String,
//      color: String,
//      charge: String,
//      note: String,
//      createdAt: Date,
//      street: String,
//      city: String,
//      zip: String
//    ) {
//      self.registration = registration
//      self.brand = brand
//      self.color = color
//      self.charge = charge
//      self.note = note
//      self.createdAt = createdAt
//      self.street = street
//      self.city = city
//      self.zip = zip
//    }
  }
  
  public enum Action: Equatable, BindableAction {
    case binding(BindingAction<EditNoticeDomain.State>)
    case updateCreatedAtDate(Date)
    case description(DescriptionDomain.Action)
  }
  
  public var body: some ReducerProtocol<State, Action> {
    
    BindingReducer()
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
    List {
//      Section(header: Text("Fotos")) {
//        LazyVGrid(columns: gridItemLayout, spacing: 12) {
//          ForEach(viewStore.images.imageStates) { image in
//            ImageView(
//              store: .init(
//                initialState: image,
//                reducer: ImageDomain()
//              )
//            )
//          }
//        }
//      }
      
//      Section {
//        EditDescriptionView(
//          store: .init(
//            initialState: viewStore.description,
//            reducer: DescriptionDomain()
//          )
//        )
//      } header: {
//        sectionHeader("Bescreibung")
//      }
            
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
        .textFieldStyle(.roundedBorder)
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
    }
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
  }
}
