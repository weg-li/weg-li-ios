import Photos

public extension CameraAccessClient {
  static let mock = Self(
    requestAuthorization: { false },
    authorizationStatus: { .notDetermined }
  )
}
