import ComposableArchitecture
import Photos

public typealias PhotoLibraryAuthorizationStatus = PHAuthorizationStatus

public struct PhotoLibraryAccessClient {
  public init(
    requestAuthorization: @escaping () -> Effect<PhotoLibraryAuthorizationStatus, Never>,
    authorizationStatus: @escaping () -> PhotoLibraryAuthorizationStatus
  ) {
    self.requestAuthorization = requestAuthorization
    self.authorizationStatus = authorizationStatus
  }
  
  public var requestAuthorization: () -> Effect<PhotoLibraryAuthorizationStatus, Never>
  public var authorizationStatus: () -> PhotoLibraryAuthorizationStatus
}
