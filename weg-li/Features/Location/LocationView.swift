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
        let resolvedLocationFromPhoto: CLLocationCoordinate2D?

        init(state: Report) {
            location = state.location
            locationOption = state.location.locationOption
            region = state.location.userLocationState.region
            isMapExpanded = state.location.isMapExpanded
            address = state.location.resolvedAddress
            showActivityIndicator = state.location.userLocationState.isRequestingCurrentLocation
                || state.location.isResolvingAddress
            resolvedLocationFromPhoto = state.images.coordinateFromImagePicker
        }
    }

    let store: Store<Report, ReportAction>
    @ObservedObject private var viewStore: ViewStore<ViewState, LocationViewAction>

    init(store: Store<Report, ReportAction>) {
        self.store = store
        viewStore = ViewStore(
            store.scope(
                state: ViewState.init,
                action: ReportAction.location
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            Picker(
                selection: viewStore.binding(
                    get: \.locationOption,
                    send: LocationViewAction.setLocationOption
                ).animation(),
                label: Text("")
            ) {
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
                            send: LocationViewAction.updateGeoAddressStreet
                        )
                    )
                    .keyboardType(RowType.street.keyboardType)
                    .textContentType(RowType.street.textContentType)
                    TextField(
                        L10n.Location.Placeholder.postalCode,
                        text: viewStore.binding(
                            get: \.address.postalCode,
                            send: LocationViewAction.updateGeoAddressPostalCode
                        )
                    )
                    .keyboardType(RowType.zipCode.keyboardType)
                    .textContentType(RowType.zipCode.textContentType)
                    TextField(
                        L10n.Location.Placeholder.city,
                        text: viewStore.binding(
                            get: \.address.city,
                            send: LocationViewAction.updateGeoAddressCity
                        )
                    )
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
                            send: LocationViewAction.updateRegion
                        ),
                        showsLocation: viewStore.locationOption == .currentLocation,
                        photoCoordinate: viewStore.binding(
                            get: \.resolvedLocationFromPhoto,
                            send: LocationViewAction.setResolvedLocation
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(height: viewStore.isMapExpanded ? 300 : 150)
                    expandMapButton
                        .padding(4)
                        .accessibility(label: Text(L10n.Location.A11y.expandButtonLabel))
                }
            }
            if viewStore.address != .empty {
                addressView
            }
        }
        .alert(
            store.scope(
                state: { $0.location.alert },
                action: { _ in ReportAction.location(.dismissAlertButtonTapped) }
            ),
            dismiss: LocationViewAction.dismissAlertButtonTapped
        )
        .onAppear { viewStore.send(.onAppear) }
    }

    @ViewBuilder private var addressView: some View {
        HStack(spacing: 4) {
            if !viewStore.showActivityIndicator && viewStore.address == .empty {
                EmptyView()
            }
            else if viewStore.showActivityIndicator {
                ActivityIndicator(style: .medium)
            } else {
                Image(systemName: "location.fill")
                    .accessibility(hidden: true)
                Text(viewStore.address.humanReadableAddress)
                    .lineLimit(2)
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
        })
            .buttonStyle(OnWidgetInteractionButtonStyle())
    }
}

struct Location_Previews: PreviewProvider {
    static var previews: some View {
        Preview {
            LocationView(
                store: .init(
                    initialState: .init(
                        images: .init(),
                        contact: .preview,
                        date: Date.init,
                        location: LocationViewState(
                            locationOption: .currentLocation,
                            isMapExpanded: false,
                            userLocationState: UserLocationState(
                                isRequestingCurrentLocation: true,
                                region: nil
                            )
                        )
                    ),
                    reducer: .empty,
                    environment: ()
                )
            )
        }
    }
}
