import CoreLocation
import SharedModels

public extension PlacesServiceClient {
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
