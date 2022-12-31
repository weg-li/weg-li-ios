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

struct EditNoticeView: View {
  public typealias S = ReportDomain.State
  public typealias A = ReportDomain.Action
  
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
    Form {
      Section {
        LazyVGrid(columns: gridItemLayout, spacing: 12) {
          ForEach(viewStore.images.imageStates) { image in
            ImageView(
              store: .init(
                initialState: image,
                reducer: ImageDomain()
              )
            )
          }
        }
      }
      
      Section {
        DatePicker(
          L10n.date,
          selection: viewStore.binding(
            get: \.date,
            send: A.setDate
          )
        )
        .labelsHidden()
      }
      
      Section {
        VStack(alignment: .leading) {
          Text("Stasse")
          Text("Stadt")
          Text("ZIP")
        }
        .padding()
      }
      
      Section {
        EditDescriptionView(
          store: store.scope(
            state: \.description,
            action: A.description
          )
        )
      }
    }
  }
}

struct SwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    EditNoticeView(
      store: .init(
        initialState: .preview,
        reducer: ReportDomain()
      )
    )
  }
}
