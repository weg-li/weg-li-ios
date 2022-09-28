import Photos

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
