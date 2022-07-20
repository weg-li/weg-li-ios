import ComposableArchitecture
import Photos

public typealias CameraAuthorizationStatus = AVAuthorizationStatus

public struct CameraAccessClient {
  public init(
    requestAuthorization: @escaping () -> Effect<Bool, Never>,
    authorizationStatus: @escaping () -> CameraAuthorizationStatus
  ) {
    self.requestAuthorization = requestAuthorization
    self.authorizationStatus = authorizationStatus
  }

  public var requestAuthorization: () -> Effect<Bool, Never>
  public var authorizationStatus: () -> CameraAuthorizationStatus
}
