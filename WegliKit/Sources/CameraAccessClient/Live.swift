import ComposableArchitecture
import Photos

public extension CameraAccessClient {
  static func live() -> Self {
    Self(
      requestAuthorization: {
        .task {
          await AVCaptureDevice.requestAccess(for: .video)
        }
      },
      authorizationStatus: {
        AVCaptureDevice.authorizationStatus(for: .video)
      }
    )
  }
}
