// Created for weg-li in 2021.

import MapKit
import SwiftUI
import SharedModels
import UIKit

struct MapView: UIViewRepresentable {
  @Binding var region: CoordinateRegion?
  private let showsLocation: Bool
  @Binding var pinCoordinate: CLLocationCoordinate2D?
  
  var placemarks: [MKPointAnnotation] = []
  
  init(
    region: Binding<CoordinateRegion?>,
    showsLocation: Bool,
    pinCoordinate: Binding<CLLocationCoordinate2D?>
  ) {
    _region = region
    self.showsLocation = showsLocation
    _pinCoordinate = pinCoordinate
  }
  
  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView(frame: .zero)
    mapView.delegate = context.coordinator
    let longPressed = UILongPressGestureRecognizer(
      target: context.coordinator,
      action: #selector(context.coordinator.addPinBasedOnGesture(_:))
    )
    mapView.addGestureRecognizer(longPressed)
    return mapView
  }
  
  func updateUIView(_ view: MKMapView, context: Context) {
    updateView(mapView: view, delegate: context.coordinator)
  }
  
  private func updateView(mapView: MKMapView, delegate: MKMapViewDelegate) {
    mapView.showsUserLocation = showsLocation
      
    if let region = self.region {
      mapView.setRegion(region.asMKCoordinateRegion, animated: true)
    }
    
    if let pinCoordinate = pinCoordinate {
      let annotation = MKPointAnnotation()
      annotation.coordinate = pinCoordinate
      
      mapView.removeAnnotations(mapView.annotations)
      mapView.addAnnotation(annotation)
    } else {
      mapView.removeAnnotations(mapView.annotations)
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
    
    @objc func addPinBasedOnGesture(_ gestureRecognizer:UIGestureRecognizer) {
      let touchPoint = gestureRecognizer.location(in: gestureRecognizer.view)
      let newCoordinates = (gestureRecognizer.view as? MKMapView)?.convert(
        touchPoint, toCoordinateFrom: gestureRecognizer.view
      )
      let annotation = MKPointAnnotation()
      guard let _newCoordinates = newCoordinates else { return }
      annotation.coordinate = _newCoordinates
              
      parent.pinCoordinate = annotation.coordinate

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      guard !annotation.isKind(of: MKUserLocation.self) else {
        // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
        return nil
      }
      
      var annotationView: MKAnnotationView?
      
      if let annotation = annotation as? MKPointAnnotation {
        annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "userPin")
      } else {
        let identifier = PhotoAnnotationView.identifier
        annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
          annotationView = PhotoAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
          annotationView?.annotation = annotation
        }
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
    MapView(
      region: .constant(nil),
      showsLocation: false,
      pinCoordinate: .constant(nil)
    )
  }
}

extension MKPointAnnotation {
  static func <(lhs: MKPointAnnotation, rhs: MKPointAnnotation) -> Bool {
    lhs.coordinate.latitude < rhs.coordinate.latitude
  }
}
