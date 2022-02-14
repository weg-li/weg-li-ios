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

public struct ReportForm: View {
  public struct ViewState: Equatable {
    public let isPhotosValid: Bool
    public let isContactValid: Bool
    public let isDescriptionValid: Bool
    public let isLocationValid: Bool
    public let isResetButtonDisabled: Bool
    
    public init(state: Report) {
      isPhotosValid = !state.images.storedPhotos.isEmpty
      isContactValid = state.contactState.isValid
      isDescriptionValid = state.description.isValid
      isLocationValid = state.location.resolvedAddress.isValid
      isResetButtonDisabled = state.location.resolvedAddress == .init()
      && state.images.storedPhotos.isEmpty
      && state.description == .init()
    }
  }
  
  private let store: Store<Report, ReportAction>
  @ObservedObject private var viewStore: ViewStore<ViewState, ReportAction>
  
  public init(store: Store<Report, ReportAction>) {
    self.store = store
    viewStore = ViewStore(store.scope(state: ViewState.init))
  }
  
  public var body: some View {
    ScrollView {
      VStack {
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
          .foregroundColor(viewStore.isResetButtonDisabled ? Color.red.opacity(0.6) : .red)
      }
    )
      .disabled(viewStore.isResetButtonDisabled)
  }
}

struct ReportForm_Previews: PreviewProvider {
  static var previews: some View {
    Preview {
      ReportForm(
        store: .init(
          initialState: .preview,
          reducer: .empty,
          environment: ()
        )
      )
    }
  }
}
