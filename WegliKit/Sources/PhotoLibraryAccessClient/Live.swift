import ComposableArchitecture
import Photos

public extension PhotoLibraryAccessClient {
  static func live(accessLevel: PHAccessLevel = .readWrite) -> Self {
    Self(
      requestAuthorization: {
        .future { promise in
          PHPhotoLibrary.requestAuthorization(for: accessLevel) { status in
            promise(.success(status))
          }
        }
      },
      authorizationStatus: {
        PHPhotoLibrary.authorizationStatus(for: accessLevel)
      }
    )
  }
}
