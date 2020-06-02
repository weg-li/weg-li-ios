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
    @State private var locationOption = 0
    @State private var isMapExpanded: Bool = false
    
    @Binding var isResolvingAddress: Bool

    init(isResolvingAddress: Binding<Bool>) {
        _isResolvingAddress = isResolvingAddress
    }
    
    var body: some View {
        
        return VStack(alignment: .leading) {
            Picker(selection: $locationOption, label: Text("")) {
                Text("Aus Fotos").tag(0)
                Text("Aktueller Ort").tag(1)
                Text("Manuell").tag(2)
            }.pickerStyle(SegmentedPickerStyle())
            ZStack(alignment: .topTrailing) {
                MapView()
                    .frame(height: self.isMapExpanded ? 300 : 150)
                expandMapButton
                    .padding(4)
                    .accessibility(label: Text("expand map"))
            }
            addressView
        }
        .padding()
    }
    
    private var addressView: some View {
        Group {
            if isResolvingAddress {
                ActivityIndicator(style: .medium, animate: $isResolvingAddress)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Straße")
                    Text("12345 Berlin")
                }
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
            }
        )
    }
}

struct Location_Previews: PreviewProvider {
    static var previews: some View {
        Location(isResolvingAddress: .constant(true))
    }
}

struct ActivityIndicator: UIViewRepresentable {
    let style: UIActivityIndicatorView.Style
    @Binding var animate: Bool

    private let spinner: UIActivityIndicatorView = {
        $0.hidesWhenStopped = true
        return $0
    }(UIActivityIndicatorView(style: .medium))

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        spinner.style = style
        return spinner
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        animate ? uiView.startAnimating() : uiView.stopAnimating()
    }

    func configure(_ indicator: (UIActivityIndicatorView) -> Void) -> some View {
        indicator(spinner)
        return self
    }
}

struct MapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}
