// Created for weg-li in 2021.

import ComposableArchitecture
import ComposableCoreLocation
import Helper
import L10n
import MapKit
import SharedModels
import Styleguide
import SwiftUI
import UIKit

public struct LocationView: View {
  public struct ViewState: Equatable {
    var alert: AlertState<LocationDomain.Action>?
    let locationOption: LocationOption
    let region: CoordinateRegion?
    let isMapExpanded: Bool
    let address: Address
    let showActivityIndicator: Bool
    let pinCoordinate: CLLocationCoordinate2D?
    
    public init(state: LocationDomain.State) {
      self.alert = state.alert
      self.locationOption = state.locationOption
      self.region = state.region
      self.isMapExpanded = state.isMapExpanded
      self.address = state.resolvedAddress
      self.showActivityIndicator = state.isRequestingCurrentLocation
        || state.isResolvingAddress
      self.pinCoordinate = state.pinCoordinate
    }
  }
  
  private let store: StoreOf<LocationDomain>
  @ObservedObject private var viewStore: ViewStore<ViewState, LocationDomain.Action>
  
  public init(store: StoreOf<LocationDomain>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: ViewState.init)
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 12.0) {
      Picker(
        selection: viewStore.binding(
          get: \.locationOption,
          send: LocationDomain.Action.setLocationOption
        ),
        label: Text("")
      ) {
        ForEach(LocationOption.allCases, id: \.self) { selection in
          Text(selection.title).tag(selection)
        }
      }.pickerStyle(.segmented)
        .accessibilityHint("Setzt die Adresse an der Anzeige")
      
      if LocationOption.manual == viewStore.locationOption {
        VStack(spacing: 8) {
          TextField(
            L10n.Location.Placeholder.street,
            text: viewStore.binding(
              get: \.address.street,
              send: LocationDomain.Action.updateGeoAddressStreet
            )
          )
          .keyboardType(RowType.street.keyboardType)
          .textContentType(RowType.street.textContentType)
          TextField(
            L10n.Location.Placeholder.postalCode,
            text: viewStore.binding(
              get: \.address.postalCode,
              send: LocationDomain.Action.updateGeoAddressPostalCode
            )
          )
          .keyboardType(RowType.zipCode.keyboardType)
          .textContentType(RowType.zipCode.textContentType)
          TextField(
            L10n.Location.Placeholder.city,
            text: viewStore.binding(
              get: \.address.city,
              send: LocationDomain.Action.updateGeoAddressCity
            )
          )
          .keyboardType(RowType.city.keyboardType)
          .textContentType(RowType.city.textContentType)
          .disableAutocorrection(true)
        }
        .multilineTextAlignment(.leading)
        .textFieldStyle(.roundedBorder)
      } else {
        ZStack(alignment: .bottomTrailing) {
          MapView(
            region: viewStore.binding(
              get: \.region,
              send: LocationDomain.Action.updateRegion
            ),
            showsLocation: viewStore.locationOption == .currentLocation,
            pinCoordinate: viewStore.binding(
              get: \.pinCoordinate,
              send: LocationDomain.Action.setPinCoordinate
            )
          )
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .frame(height: viewStore.isMapExpanded ? 300 : 150)
          expandMapButton
            .padding(.grid(1))
            .accessibility(label: Text(L10n.Location.A11y.expandButtonLabel))
        }
      }
      addressView
    }
    .transition(.opacity)
    .alert(
      item: viewStore.binding(
        get: { $0.alert },
        send: .onDismissAlertButtonTapped
      ),
      content: { Alert(title: Text($0.title)) }
    )
    .onAppear { viewStore.send(.onAppear) }
  }
  
  @ViewBuilder var addressView: some View {
    HStack(spacing: .grid(2)) {
      if viewStore.showActivityIndicator {
        HStack {
          ProgressView()
            .padding(.trailing, 4)
          Text("Suche Adresse ...")
        }
      } else if !viewStore.showActivityIndicator, viewStore.address == .init() {
        EmptyView()
      } else {
        Image(systemName: "location.fill")
          .accessibility(hidden: true)
        Text(viewStore.address.humanReadableAddress())
          .lineLimit(2)
      }
    }
    .transition(.opacity)
    .font(.body)
  }
  
  var expandMapButton: some View {
    Button(action: {
      viewStore.send(.onToggleMapExpandedTapped)
    }, label: {
      Image(systemName: viewStore.isMapExpanded
        ? "arrow.down.right.and.arrow.up.left"
        : "arrow.up.left.and.arrow.down.right"
      )
    })
    .buttonStyle(.widgetInteraction())
  }
}

struct Location_Previews: PreviewProvider {
  static var previews: some View {
    Preview {
      LocationView(
        store: Store(
          initialState: LocationDomain.State(
            locationOption: .currentLocation,
            isMapExpanded: false,
            isRequestingCurrentLocation: true,
            region: nil
          ),
          reducer: { LocationDomain() }
        )
      )
    }
  }
}
