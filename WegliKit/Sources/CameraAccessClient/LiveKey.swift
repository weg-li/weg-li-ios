import Dependencies
import Photos

extension CameraAccessClient: DependencyKey {
  public static var liveValue: CameraAccessClient = .live()
  
  static func live() -> Self {
    Self(
      requestAuthorization: { await AVCaptureDevice.requestAccess(for: .video) },
      authorizationStatus: { AVCaptureDevice.authorizationStatus(for: .video) }
    )
  }
}
