import Photos

public extension CameraAccessClient {
  static func live() -> Self {
    Self(
      requestAuthorization: { await AVCaptureDevice.requestAccess(for: .video) },
      authorizationStatus: { AVCaptureDevice.authorizationStatus(for: .video) }
    )
  }
}
