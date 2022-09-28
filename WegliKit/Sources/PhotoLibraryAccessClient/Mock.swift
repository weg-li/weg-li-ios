import Photos

public extension PhotoLibraryAccessClient {
  static let noop = Self(
    requestAuthorization: { .notDetermined },
    authorizationStatus: { .notDetermined }
  )
}
