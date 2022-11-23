import Dependencies
import Photos

extension PhotoLibraryAccessClient: DependencyKey {
  public static var liveValue: PhotoLibraryAccessClient { .live() }
  
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
