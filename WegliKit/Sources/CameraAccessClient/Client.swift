import Dependencies
import Photos

extension DependencyValues {
  public var cameraAccessClient: CameraAccessClient {
    get { self[CameraAccessClient.self] }
    set { self[CameraAccessClient.self] = newValue }
  }
}


// MARK: Client interface


public typealias CameraAuthorizationStatus = AVAuthorizationStatus

public struct CameraAccessClient {
  public init(
    requestAuthorization: @escaping () async -> Bool,
    authorizationStatus: @escaping () -> CameraAuthorizationStatus
  ) {
    self.requestAuthorization = requestAuthorization
    self.authorizationStatus = authorizationStatus
  }

  public var requestAuthorization: () async -> Bool
  public var authorizationStatus: () -> CameraAuthorizationStatus
}
