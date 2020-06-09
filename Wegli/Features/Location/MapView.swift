//
//  MapView.swift
//  Wegli
//
//  Created by Malte Bünz on 08.06.20.
//  Copyright © 2020 Stefan Trauth. All rights reserved.
//

import MapKit
import SwiftUI
import UIKit

struct MapView: UIViewRepresentable {
//    var initialCoordinate: CLLocationCoordinate2D
    @Binding var center: CLLocationCoordinate2D
    var annotations: [MKPointAnnotation]
    
    init(center: Binding<CLLocationCoordinate2D>) {
        self._center = center
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center.wrappedValue
        self.annotations = [annotation]
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        center(view, on: center)
        syncAnnototations(in: view)
    }
    
    private func syncAnnototations(in view: MKMapView) {
        if annotations.count != view.annotations.count {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
        }
    }
    
    private func center(_ view: MKMapView, on coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        let adjustedRegion = view.regionThatFits(region)
        view.setRegion(adjustedRegion, animated: true)
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

class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    init(_ parent: MapView) {
        self.parent = parent
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        parent.center = mapView.centerCoordinate
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

#if DEBUG
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(center: .constant(CLLocationCoordinate2D()))
    }
}
#endif
