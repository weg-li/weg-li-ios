// Created for weg-li in 2021.

import CoreLocation
import Foundation
import MapKit

public struct CoordinateRegion: Equatable {
  public init(center: CLLocationCoordinate2D, span: MKCoordinateSpan) {
    self.center = center
    self.span = span
  }
  
  public var center: CLLocationCoordinate2D
  public var span: MKCoordinateSpan
  
  public var asMKCoordinateRegion: MKCoordinateRegion {
    .init(center: center, span: span)
  }
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.center.latitude == rhs.center.latitude
    && lhs.center.longitude == rhs.center.longitude
    && lhs.span.latitudeDelta == rhs.span.latitudeDelta
    && lhs.span.longitudeDelta == rhs.span.longitudeDelta
  }
}

public extension CoordinateRegion {
  /// Initialize with center coordinate
  /// - Parameters:
  ///   - center: Coordinate of the region center.
  ///   - span: Zoom level with a default value of 0.02
  init(
    center: CLLocationCoordinate2D,
    defaultSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
  ) {
    self.center = center
    self.span = defaultSpan
  }
  
  init(coordinateRegion: MKCoordinateRegion) {
    center = coordinateRegion.center
    span = coordinateRegion.span
  }
}
