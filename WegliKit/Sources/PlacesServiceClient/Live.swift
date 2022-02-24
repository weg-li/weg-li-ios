import ComposableArchitecture
import CoreLocation
import SharedModels

public extension PlacesServiceClient {
  static let live = Self(
    placemarks: { location in
      Effect.task {
        do {
          let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
          return transformPlacemarks(placemarks)
        } catch {
          debugPrint(error.localizedDescription)
          return []
        }
      }
      .setFailureType(to: PlacesServiceError.self)
      .eraseToEffect()
    }
  )
}
