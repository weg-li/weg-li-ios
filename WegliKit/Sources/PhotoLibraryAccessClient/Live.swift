import Photos

public extension PhotoLibraryAccessClient {
  static func live(accessLevel: PHAccessLevel = .readWrite) -> Self {
    Self(
      requestAuthorization: {
        await PHPhotoLibrary.requestAuthorization(for: accessLevel)
      },
      authorizationStatus: {
        PHPhotoLibrary.authorizationStatus(for: accessLevel)
      }
    )
  }
}
