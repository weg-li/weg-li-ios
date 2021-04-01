//
//  MapView.swift
//  weg-li
//
//  Created by Malte Bünz on 08.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import MapKit
import SwiftUI
import UIKit

struct MapView: UIViewRepresentable {
    @Binding var region: CoordinateRegion?
    private let showsLocation: Bool
    
    init(region: Binding<CoordinateRegion?>, showsLocation: Bool) {
        self._region = region
        self.showsLocation = showsLocation
    }
    
   func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView(frame: .zero)
        mapView.showsUserLocation = showsLocation
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        self.updateView(mapView: view, delegate: context.coordinator)
    }
        
    private func updateView(mapView: MKMapView, delegate: MKMapViewDelegate) {
        mapView.delegate = delegate
        
        mapView.showsUserLocation = showsLocation
        
        if let region = self.region {
            mapView.setRegion(region.asMKCoordinateRegion, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        init(_ parent: MapView) {
            self.parent = parent
        }
                
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.region = CoordinateRegion(
                center: mapView.region.center,
                span: mapView.region.span
            )
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "PlaceMark"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(region: .constant(nil), showsLocation: true)
    }
}
