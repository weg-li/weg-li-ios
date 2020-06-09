//
//  Location.swift
//  Wegli
//
//  Created by Stefan Trauth on 09.10.19.
//  Copyright © 2019 Stefan Trauth. All rights reserved.
//

import SwiftUI
import MapKit
import UIKit

struct Location: View {
    @EnvironmentObject private var store: AppStore
    
    @State private var isMapExpanded: Bool = false
    @State private var isResolvingAddress: Bool = false
    @State private var locationOption: Int = 0
    @State private var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var body: some View {
        VStack(alignment: .leading) {
            Picker(selection: $locationOption.onChange(optionChange), label: Text("")) {
                ForEach(locationOptions, id: \.self) { option in
                    option.text
                }
            }.pickerStyle(SegmentedPickerStyle())
            ZStack(alignment: .topTrailing) {
                MapView(center: $currentLocation)
                    .frame(height: self.isMapExpanded ? 300 : 150)
                expandMapButton
                    .padding(4)
                    .accessibility(label: Text("expand map"))
            }
            addressView
        }
    }
    
    private var locationOptions: [LocationOption] {
        if store.state.report.images.isEmpty {
            return [.currentLocation, .manual]
        } else {
            return LocationOption.allCases
        }
    }
    
    private var addressView: some View {
        Group {
            if store.state.location.location.latitude.isNaN {
                ActivityIndicator(style: .medium, animate: $isResolvingAddress)
                    .eraseToAnyView()
            } else if store.state.location.presumedAddress != nil {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.state.location.presumedAddress!.humanReadableAddress)
                        .lineLimit(nil)
                        .fixedSize(horizontal: true, vertical: false)
                }.eraseToAnyView()
            } else {
                EmptyView().eraseToAnyView()
            }
        }
    }
    
    private var expandMapButton: some View {
        Button(action: {
            withAnimation {
                self.isMapExpanded.toggle()
            }
        }, label: {
            Image(systemName: self.isMapExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right" )
                .padding()
                .background(
                    Color.white
                        .clipShape(Circle())
            )
                .accessibility(hidden: true)
        })
    }
    
    private func optionChange(_ option: Int) {
        store.send(.resolveAddress(LocationOption.init(rawValue: option)!))
    }
}

extension Location {
    enum LocationOption: Int, CaseIterable {
        case fromPhotos
        case currentLocation
        case manual
        
        var text: some View {
            switch self {
            case .fromPhotos:
                return Text("Aus Fotos").tag(rawValue)
            case .currentLocation:
                return Text("Aktuelle Position").tag(rawValue)
            case .manual:
                return Text("Manuell").tag(rawValue)
            }
        }
    }
}

struct Location_Previews: PreviewProvider {
    static var previews: some View {
        Location()
    }
}
