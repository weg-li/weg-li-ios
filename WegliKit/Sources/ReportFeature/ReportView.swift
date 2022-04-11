// Created for weg-li in 2021.

import ComposableArchitecture
import ContactFeature
import DescriptionFeature
import Helper
import L10n
import ImagesFeature
import LocationFeature
import Styleguide
import SwiftUI

public struct ReportView: View {
  private let store: Store<Report, ReportAction>
  @ObservedObject private var viewStore: ViewStore<Report, ReportAction>
    
  public init(store: Store<Report, ReportAction>) {
    self.store = store
    viewStore = ViewStore(store)
  }
  
  public var body: some View {
    ScrollView {
      VStack {
        Widget(
          title: Text("Datum"),
          isCompleted: true
        ) {
          VStack(alignment: .leading) {
            DatePicker(
              "Datum",
              selection: viewStore.binding(
                get: \.date,
                send: ReportAction.setDate
              )
            )
            .labelsHidden()
            .padding(.bottom)
            
            Text("Beim auswählen eines Fotos wird das Datum aus den Metadaten ausgelesen")
              .multilineTextAlignment(.leading)
              .foregroundColor(Color(.secondaryLabel))
              .font(.callout)
          }
        }
        // Photos
        Widget(
          title: Text(L10n.Photos.widgetTitle),
          isCompleted: viewStore.isPhotosValid
        ) {
          ImagesView(
            store: store.scope(
              state: \.images,
              action: ReportAction.images
            )
          )
        }
        
        // Location
        Widget(
          title: Text(L10n.Location.widgetTitle),
          isCompleted: viewStore.isLocationValid
        ) {
          LocationView(
            store: store.scope(
              state: \.location,
              action: ReportAction.location
            )
          )
        }
        
        // Description
        Widget(
          title: Text(L10n.Description.widgetTitle),
          isCompleted: viewStore.isDescriptionValid
        ) { DescriptionView(store: store) }
        
        // Contact
        Widget(
          title: Text(L10n.Report.Contact.widgetTitle),
          isCompleted: viewStore.isContactValid
        ) { ContactWidget(store: store.scope(state: { $0 })) }
        
        // Mail
        MailContentView(store: store)
          .padding()
      }
    }
    .alert(store.scope(state: { $0.alert }), dismiss: .dismissAlert)
    .navigationBarItems(trailing: resetButton)
    .navigationBarTitle(L10n.Report.navigationBarTitle, displayMode: .inline)
  }
  
  private var resetButton: some View {
    Button(
      action: { viewStore.send(.resetButtonTapped) },
      label: {
        Image(systemName: "arrow.counterclockwise")
          .foregroundColor(viewStore.isResetButtonDisabled ? .gray : .red)
      }
    )
      .disabled(viewStore.isResetButtonDisabled)
  }
}

struct ReportForm_Previews: PreviewProvider {
  static var previews: some View {
    Preview {
      ReportView(
        store: .init(
          initialState: .preview,
          reducer: .empty,
          environment: ()
        )
      )
    }
  }
}
