import Dependencies
import Photos
import XCTestDynamicOverlay

extension PhotoLibraryAccessClient: TestDependencyKey {
  public static let noop = Self(
    requestAuthorization: { .notDetermined },
    authorizationStatus: { .notDetermined }
  )
  
  public static var testValue: PhotoLibraryAccessClient = Self(
    requestAuthorization: unimplemented("\(Self.self).requestAuthorization", placeholder: .notDetermined),
    authorizationStatus: unimplemented("\(Self.self).authorizationStatus", placeholder: .notDetermined)
  )
}
