// Created for weg-li in 2021.

import MapKit
import SwiftUI
import SharedModels
import UIKit

struct MapView: UIViewRepresentable {
  @Binding var region: CoordinateRegion?
  private let showsLocation: Bool
  @Binding var photoCoordinate: CLLocationCoordinate2D?
  
  init(
    region: Binding<CoordinateRegion?>,
    showsLocation: Bool,
    photoCoordinate: Binding<CLLocationCoordinate2D?>
  ) {
    _region = region
    self.showsLocation = showsLocation
    _photoCoordinate = photoCoordinate
  }
  
  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView(frame: .zero)
    return mapView
  }
  
  func updateUIView(_ view: MKMapView, context: Context) {
    updateView(mapView: view, delegate: context.coordinator)
  }
  
  private func updateView(mapView: MKMapView, delegate: MKMapViewDelegate) {
    mapView.delegate = delegate
    mapView.showsUserLocation = showsLocation
    
    if let region = self.region {
      mapView.setRegion(region.asMKCoordinateRegion, animated: false)
    }
    
    let currentlyDisplayedPOIs = mapView.annotations.compactMap { $0 as? PointOfInterestAnnotation }
    
    if currentlyDisplayedPOIs.filter({ $0.coordinate == photoCoordinate }).isEmpty {
      mapView.removeAnnotations(currentlyDisplayedPOIs)
    }
    
    if let photoCoordinate = self.photoCoordinate {
      let annotation = PointOfInterestAnnotation(coordinate: photoCoordinate)
      mapView.addAnnotations([annotation])
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
      let identifier = PhotoAnnotationView.identifier
      var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
      if annotationView == nil {
        annotationView = PhotoAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      } else {
        annotationView?.annotation = annotation
      }
      return annotationView
    }
  }
}

private class PointOfInterestAnnotation: NSObject, MKAnnotation {
  init(coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
  }
  
  let coordinate: CLLocationCoordinate2D
}

final class PhotoAnnotationView: MKMarkerAnnotationView {
  static let identifier = "PhotoAnnotationView"
  
  override func prepareForDisplay() {
    super.prepareForDisplay()
    commonInit()
  }
  
  private func commonInit() {
    animatesWhenAdded = false
    glyphImage = UIImage(systemName: "camera")
    canShowCallout = false
  }
}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView(region: .constant(nil), showsLocation: false, photoCoordinate: .constant(.zero))
  }
}
