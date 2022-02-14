import ComposableArchitecture
import Photos

public extension PhotoLibraryAccessClient {
  static let noop = Self(
    requestAuthorization: { .none },
    authorizationStatus: { .notDetermined }
  )  
}

