import CoreLocation
import Dependencies
import SharedModels

extension PlacesServiceClient: DependencyKey {
  public static var liveValue: PlacesServiceClient = Self.live
  
  static let live = Self(
    placemarks: { location in
      do {
        let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
        return transformPlacemarks(placemarks)
      } catch {
        debugPrint(error.localizedDescription)
        return []
      }
    }
  )
}
