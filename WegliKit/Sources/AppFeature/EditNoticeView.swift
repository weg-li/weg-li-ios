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
//    @BindableState public var registration: String
//    @BindableState public var brand: String
//    @BindableState public var color: String
//    @BindableState public var charge: String
//    @BindableState public var note: String
    
    public var description: DescriptionDomain.State
    
    @BindableState public var createdAt: Date
    
    @BindableState public var street: String
    @BindableState public var city: String
    @BindableState public var zip: String
    
    init(description: DescriptionDomain.State, createdAt: Date, street: String, city: String, zip: String) {
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
      
      Section {
        EditDescriptionView(
          store: .init(
            initialState: viewStore.description,
            reducer: DescriptionDomain()
          )
        )
        
//        TextField(
//          L10n.Description.Row.licenseplateNumber,
//          text: viewStore.binding(\.$registration)
//        )
//        TextField(
//          L10n.Description.Row.carType,
//          text: viewStore.binding(\.$brand)
//        )
//        TextField(
//          L10n.Description.Row.carColor,
//          text: viewStore.binding(\.$color)
//        )
//        TextField(
//          L10n.Description.Row.chargeType,
//          text: viewStore.binding(\.$charge)
//        )
        
      } header: {
        sectionHeader("Bescreibung")
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
        .textFieldStyle(.roundedBorder)
      } header: {
        sectionHeader("Adresse")
      }
      
      Section {
        DatePicker(
          L10n.date,
          selection: viewStore.binding(\.$createdAt)
        )
        .labelsHidden()
      } header: {
        sectionHeader("Datum")
      }
      
//      EditDescriptionView(
//        store: store.scope(
//          state: \.description,
//          action: A.description
//        )
//      )
    }
  }
  
  @ViewBuilder
  func sectionHeader(_ text: String) -> some View {
    SectionHeader(text: text)
  }
}

//struct SwiftUIView_Previews: PreviewProvider {
//  static var previews: some View {
//    EditNoticeView(
//      store: .init(
//        initialState: .preview,
//        reducer: ReportDomain()
//      )
//    )
//  }
//}


extension EditNoticeDomain.State {
  init(notice: Notice) {
    self.createdAt = notice.createdAt ?? .now
    self.street = notice.street ?? ""
    self.city = notice.city ?? ""
    self.zip = notice.zip ?? ""
    self.description = .init(model: notice)
//    self.charge = notice.charge ?? ""
//    self.note = notice.note ?? ""
//    self.color = notice.color ?? ""
//    self.registration = notice.registration ?? ""
//    self.brand = notice.brand ?? ""
  }
}
