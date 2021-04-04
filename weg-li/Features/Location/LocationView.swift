// Created for weg-li in 2021.

import ComposableArchitecture
import MapKit
import SwiftUI
import UIKit

struct LocationView: View {
    struct ViewState: Equatable {
        let location: LocationViewState
        let locationOption: LocationOption
        let region: CoordinateRegion?
        let isMapExpanded: Bool
        let address: GeoAddress
        let showActivityIndicator: Bool

        init(state: Report) {
            location = state.location
            locationOption = state.location.locationOption
            region = state.location.userLocationState.region
            isMapExpanded = state.location.isMapExpanded
            address = state.location.resolvedAddress
            showActivityIndicator = state.location.userLocationState.isRequestingCurrentLocation
                || state.location.isResolvingAddress
        }
    }

    let store: Store<Report, ReportAction>
    @ObservedObject private var viewStore: ViewStore<ViewState, LocationViewAction>

    init(store: Store<Report, ReportAction>) {
        self.store = store
        viewStore = ViewStore(
            store.scope(
                state: ViewState.init,
                action: ReportAction.location)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            Picker(
                selection: viewStore.binding(
                    get: \.locationOption,
                    send: LocationViewAction.setLocationOption).animation(),
                label: Text("")) {
                    ForEach(LocationOption.allCases, id: \.self) { selection in
                        Text(selection.title).tag(selection)
                    }
            }.pickerStyle(SegmentedPickerStyle())
            if LocationOption.manual == viewStore.locationOption {
                VStack(spacing: 8) {
                    TextField(
                        L10n.Location.Placeholder.street,
                        text: viewStore.binding(
                            get: \.address.street,
                            send: LocationViewAction.updateGeoAddressStreet))
                        .keyboardType(RowType.street.keyboardType)
                        .textContentType(RowType.street.textContentType)
                    TextField(
                        L10n.Location.Placeholder.postalCode,
                        text: viewStore.binding(
                            get: \.address.postalCode,
                            send: LocationViewAction.updateGeoAddressPostalCode))
                        .keyboardType(RowType.zipCode.keyboardType)
                        .textContentType(RowType.zipCode.textContentType)
                    TextField(
                        L10n.Location.Placeholder.city,
                        text: viewStore.binding(
                            get: \.address.city,
                            send: LocationViewAction.updateGeoAddressCity))
                        .keyboardType(RowType.town.keyboardType)
                        .textContentType(RowType.town.textContentType)
                        .disableAutocorrection(true)
                }
                .multilineTextAlignment(.leading)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                ZStack(alignment: .topTrailing) {
                    MapView(
                        region: viewStore.binding(
                            get: \.region,
                            send: LocationViewAction.updateRegion),
                        showsLocation: viewStore.locationOption == .currentLocation)
                        .frame(height: viewStore.isMapExpanded ? 300 : 150)
                    expandMapButton
                        .padding(4)
                        .accessibility(label: Text(L10n.Location.A11y.expandButtonLabel))
                }
            }
            addressView
        }
        .alert(
            store.scope(state: { $0.location.userLocationState.alert }),
            dismiss: ReportAction.location(.dismissAlertButtonTapped))
        .onAppear { viewStore.send(.onAppear) }
    }

    @ViewBuilder private var addressView: some View {
        HStack(spacing: 4) {
            Image(systemName: "location.fill")
                .accessibility(hidden: true)
            if viewStore.showActivityIndicator {
                ActivityIndicator(style: .medium)
            } else {
                Text(viewStore.address.humanReadableAddress)
                    .lineLimit(nil)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .font(.body)
    }

    private var expandMapButton: some View {
        Button(action: {
            withAnimation {
                viewStore.send(.toggleMapExpanded)
            }
        }, label: {
            Image(systemName: viewStore.isMapExpanded
                ? "arrow.down.right.and.arrow.up.left"
                : "arrow.up.left.and.arrow.down.right"
            )
            .padding()
            .foregroundColor(Color(.label))
            .background(
                Color(.systemFill)
                    .clipShape(Circle())
            )
            .accessibility(hidden: true)
        })
    }
}

struct Location_Previews: PreviewProvider {
    static var previews: some View {
        LocationView(
            store: .init(
                initialState: .init(
                    images: .init(),
                    contact: .preview,
                    location: LocationViewState(
                        locationOption: .manual,
                        isMapExpanded: false,
                        storedPhotos: [],
                        userLocationState: UserLocationState(
                            alert: nil,
                            isRequestingCurrentLocation: true,
                            region: nil))),
                reducer: .empty,
                environment: ())
        )
//        .preferredColorScheme(.dark)
//        .environment(\.sizeCategory, .large)
    }
}

extension CLLocationCoordinate2D {
    static let zero = CLLocationCoordinate2D(latitude: 0, longitude: 0)
}

extension LocationOption {
    var text: some View {
        switch self {
        case .fromPhotos:
            return Text(L10n.Location.PickerCopy.fromPhotos)
        case .currentLocation:
            return Text(L10n.Location.PickerCopy.currentLocation)
        case .manual:
            return Text(L10n.Location.PickerCopy.fromPhotos)
        }
    }
}
