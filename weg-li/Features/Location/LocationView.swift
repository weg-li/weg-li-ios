//
//  Location.swift
//  weg-li
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

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
            self.location = state.location
            self.locationOption = state.location.locationOption
            self.region = state.location.userLocationState.region
            self.isMapExpanded = state.location.isMapExpanded
            self.address = state.location.resolvedAddress
            self.showActivityIndicator = state.location.userLocationState.isRequestingCurrentLocation
                || state.location.isResolvingAddress
        }
    }
    
    let store: Store<Report, ReportAction>
    @ObservedObject private var viewStore: ViewStore<ViewState, ReportAction>
    
    init(store: Store<Report, ReportAction>) {
        self.store = store
        self.viewStore = ViewStore(store.scope(state: ViewState.init))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6.0) {
            Picker(
                selection: viewStore.binding(
                    get: \.locationOption,
                    send: { ReportAction.location(.setLocationOption($0)) }
                ).animation(),
                label: Text("")
            ) {
                ForEach(LocationOption.allCases, id: \.self) { selection in
                    Text(selection.title).tag(selection)
                }
            }.pickerStyle(SegmentedPickerStyle())
            ZStack(alignment: .topTrailing) {
                MapView(
                    region: viewStore.binding(
                        get: \.region,
                        send: { ReportAction.location(.updateRegion($0)) }
                    ),
                    showsLocation: viewStore.locationOption == .currentLocation
                )
                .frame(height: viewStore.isMapExpanded ? 300 : 150)
                expandMapButton
                    .padding(4)
                    .accessibility(label: Text("expand map"))
            }
            addressView
        }
        .alert(
            store.scope(state: { $0.location.userLocationState.alert }),
            dismiss: ReportAction.location(.dismissAlertButtonTapped)
        )
        .onAppear { viewStore.send(.location(.onAppear)) }
    }
        
    @ViewBuilder private var addressView: some View {
        if viewStore.showActivityIndicator {
            ActivityIndicator(style: .medium)
        } else {
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                Text(viewStore.address.humanReadableAddress)
                    .lineLimit(nil)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .font(.body)
        }
    }
    
    private var expandMapButton: some View {
        Button(action: {
            withAnimation {
                viewStore.send(.location(.toggleMapExpanded))
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
                        locationOption: .fromPhotos(nil),
                        isMapExpanded: false,
                        storedPhotos: [],
                        userLocationState: UserLocationState(
                            alert: nil,
                            isRequestingCurrentLocation: true,
                            region: nil
                        )
                    )
                ),
                reducer: .empty,
                environment: ()
            )
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
            return Text("Aus Fotos")
        case .currentLocation:
            return Text("Aktuelle Position")
        case .manual:
            return Text("Manuell")
        }
    }
}
