import Dependencies
import Foundation
import XCTestDynamicOverlay

extension PlacesServiceClient: TestDependencyKey {
  public static let noop = Self(
    placemarks: { _ in [] }
  )
  
  public static let testValue: PlacesServiceClient = Self(
    placemarks: unimplemented("\(Self.self).placemarks", placeholder: [])
  )
}
