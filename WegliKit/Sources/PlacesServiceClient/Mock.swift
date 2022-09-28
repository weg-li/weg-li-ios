import Foundation

public extension PlacesServiceClient {
  static let noop = Self(
    placemarks: { _ in [] }
  )
}
