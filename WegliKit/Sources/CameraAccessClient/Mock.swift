import ComposableArchitecture
import Photos

public extension CameraAccessClient {
  static let mock = Self(
    requestAuthorization: { .none },
    authorizationStatus: { .notDetermined }
  )
}
