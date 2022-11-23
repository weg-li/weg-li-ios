import Dependencies
import Photos
import XCTestDynamicOverlay

extension CameraAccessClient: TestDependencyKey {
  public static let mock = Self(
    requestAuthorization: { false },
    authorizationStatus: { .notDetermined }
  )
  
  public static let testValue: CameraAccessClient = Self(
    requestAuthorization: unimplemented("\(Self.self).requestAuthorization", placeholder: false),
    authorizationStatus: unimplemented("\(Self.self).authorizationStatus", placeholder: .notDetermined)
  )
}
