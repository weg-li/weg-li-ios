import CameraAccessClient
import Combine
import ComposableArchitecture
import Foundation
import ImagesFeature
import XCTest

@MainActor
final class CameraAccessTests: XCTestCase {
  let scheduler = DispatchQueue.immediate.eraseToAnyScheduler()

  func test_cameraButtonTapped_shouldRequestAccess_andPresentCamera_whenAuthorised() async {
    let accessClient = CameraAccessClient(
      requestAuthorization: { true },
      authorizationStatus: { .notDetermined }
    )

    let store = TestStore(
      initialState: ImagesViewDomain.State(
        showCamera: false,
        storedPhotos: []
      ),
      reducer: ImagesViewDomain(),
      prepareDependencies: { values in
        values.continuousClock = ImmediateClock()
        values.cameraAccessClient = accessClient
        values.photoLibraryAccessClient = .noop
        values.textRecognitionClient = .noop
        
      }
    )

    await store.send(.onTakePhotosButtonTapped)
    await store.receive(.requestCameraAccess)
    await store.receive(.requestCameraAccessResult(.success(true)))
    await store.receive(.setShowCamera(true)) {
      $0.showCamera = true
    }
  }
}
