import Dependencies
import Photos

extension DependencyValues {
  public var photoLibraryAccessClient: PhotoLibraryAccessClient {
    get { self[PhotoLibraryAccessClient.self] }
    set { self[PhotoLibraryAccessClient.self] = newValue }
  }
}


// MARK: Client interface


public typealias PhotoLibraryAuthorizationStatus = PHAuthorizationStatus

public struct PhotoLibraryAccessClient {
  public init(
    requestAuthorization: @escaping () async -> PhotoLibraryAuthorizationStatus,
    authorizationStatus: @escaping () -> PhotoLibraryAuthorizationStatus
  ) {
    self.requestAuthorization = requestAuthorization
    self.authorizationStatus = authorizationStatus
  }
  
  public var requestAuthorization: () async -> PhotoLibraryAuthorizationStatus
  public var authorizationStatus: () -> PhotoLibraryAuthorizationStatus
}
