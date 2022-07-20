import ComposableArchitecture
import Photos

public extension CameraAccessClient {
  static func live() -> Self {
    Self(
      requestAuthorization: {
        .future { promise in
          AVCaptureDevice.requestAccess(for: .video) { status in
            promise(.success(status))
          }
        }
      },
      authorizationStatus: {
        AVCaptureDevice.authorizationStatus(for: .video)
      }
    )
  }
}
