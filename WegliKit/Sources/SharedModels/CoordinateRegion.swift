// Created for weg-li in 2021.

import CoreLocation
import Foundation
import MapKit

public struct CoordinateRegion: Equatable, Codable {
  public init(center: Coordinate, span: Span) {
    self.center = center
    self.span = span
  }
  
  public var center: Coordinate
  public var span: Span
  
  public var asMKCoordinateRegion: MKCoordinateRegion {
    .init(center: center.asCLLocationCoordinate2D, span: span.asMKCoordinateSpan)
  }
}

public extension CoordinateRegion {
  /// Initialize with center coordinate
  /// - Parameters:
  ///   - center: Coordinate of the region center.
  ///   - span: Zoom level with a default value of 0.02
  init(
    center: CLLocationCoordinate2D,
    defaultSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
  ) {
    self.center = .init(center)
    self.span = .init(defaultSpan)
  }
  
  init(coordinateRegion: MKCoordinateRegion) {
    center = .init(coordinateRegion.center)
    span = .init(coordinateRegion.span)
  }
}

public extension CoordinateRegion {
  struct Coordinate: Equatable, Codable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
      self.latitude = latitude
      self.longitude = longitude
    }
    
    public var asCLLocationCoordinate2D: CLLocationCoordinate2D {
      CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
  }
  
  struct Span: Equatable, Codable {
    public let latitudeDelta: Double
    public let longitudeDelta: Double

    public init(latitudeDelta: Double, longitudeDelta: Double) {
      self.latitudeDelta = latitudeDelta
      self.longitudeDelta = longitudeDelta
    }
    
    public var asMKCoordinateSpan: MKCoordinateSpan {
      .init(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
  }
}

public extension CoordinateRegion.Span {
  init(_ span: MKCoordinateSpan) {
    self.latitudeDelta = span.latitudeDelta
    self.longitudeDelta = span.longitudeDelta
  }
}

public extension CoordinateRegion.Coordinate {
  init(_ coordinate: CLLocationCoordinate2D) {
    self.latitude = coordinate.latitude
    self.longitude = coordinate.longitude
  }
}
