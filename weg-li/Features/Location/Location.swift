//
//  Location.swift
//  weg-li
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI
import MapKit
import UIKit

struct Location: View {
//    @EnvironmentObject private var store: AppStore
    
    @State private var isMapExpanded: Bool = false
    @State private var isResolvingAddress: Bool = false
    @State private var locationOption: Int = 0
    @State private var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var body: some View {
        VStack(alignment: .leading) {
            Picker(selection: $locationOption.onChange(optionChange), label: Text("")) {
                ForEach(0..<locationOptions.count) { option in
                    self.locationOptions[option].text
                }
            }.pickerStyle(SegmentedPickerStyle())
            ZStack(alignment: .topTrailing) {
//                MapView(center: store.state.location.location)
//                    .frame(height: self.isMapExpanded ? 300 : 150)
//                expandMapButton
//                    .padding(4)
//                    .accessibility(label: Text("expand map"))
            }
            addressView
        }
        .onAppear {
//            self.store.send(.handleLocationAction(.onLocationAppear))
        }
    }
    
    private var locationOptions: [LocationOption] {
//        if store.state.report.images.isEmpty {
//            return [.currentLocation(.zero), .manual]
//        } else {
            return [.fromPhotos, .currentLocation(.zero), .manual]
//        }
    }
    
    @ViewBuilder private var addressView: some View {
//        if store.state.location.location == .zero {
            ActivityIndicator(style: .medium, animate: $isResolvingAddress)
//        } else if store.state.location.presumedAddress != nil {
//            VStack(alignment: .leading, spacing: 4) {
//                Text(store.state.location.presumedAddress!.humanReadableAddress)
//                    .lineLimit(nil)
//                    .fixedSize(horizontal: true, vertical: false)
//            }
//        } else {
//            EmptyView()
//        }
    }
    
    private var expandMapButton: some View {
        Button(action: {
            withAnimation {
                self.isMapExpanded.toggle()
            }
        }, label: {
            Image(systemName: self.isMapExpanded
                ? "arrow.down.right.and.arrow.up.left"
                : "arrow.up.left.and.arrow.down.right"
            )
                .padding()
                .background(
                    Color.white
                        .clipShape(Circle())
            )
                .accessibility(hidden: true)
        })
    }
    
    private func optionChange(_ option: Int) {
//        store.send(.handleLocationAction(.resolveAddress(locationOptions[option])))
    }
}

import CoreLocation

extension Location {
    enum LocationOption {
        init?(index: Int) {
            switch index {
            case 0: self = .fromPhotos
            case 1: self = .currentLocation(.zero)
            case 2: self = .manual
            default: return nil
            }
        }
        
        case fromPhotos
        case currentLocation(CLLocationCoordinate2D)
        case manual
        
        var index: Int {
            switch self {
            case .fromPhotos: return 0
            case .currentLocation: return 1
            case .manual: return 2
            }
        }
        
        var text: some View {
            switch self {
            case .fromPhotos:
                return Text("Aus Fotos").tag(index)
            case .currentLocation:
                return Text("Aktuelle Position").tag(index)
            case .manual:
                return Text("Manuell").tag(index)
            }
        }
    }
}

struct Location_Previews: PreviewProvider {
    static var previews: some View {
        Location()
    }
}

extension CLLocationCoordinate2D {
    static let zero = CLLocationCoordinate2D(latitude: 0, longitude: 0)
}
