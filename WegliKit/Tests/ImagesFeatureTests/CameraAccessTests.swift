import CameraAccessClient
import Combine
import ComposableArchitecture
import Foundation
import ImagesFeature
import XCTest

class CameraAccessTests: XCTestCase {
  let scheduler = DispatchQueue.immediate.eraseToAnyScheduler()

  func test_cameraButtonTapped_shouldRequestAccess_andPresentCamera_whenAuthorised() {
    let subject = CurrentValueSubject<Bool, Never>(true)
    let accessClient = CameraAccessClient(
      requestAuthorization: {
        Effect(subject)
      },
      authorizationStatus: { .notDetermined }
    )

    let store = TestStore(
      initialState: ImagesViewState(
        showCamera: false,
        storedPhotos: []
      ),
      reducer: imagesReducer,
      environment: ImagesViewEnvironment(
        mainQueue: scheduler,
        backgroundQueue: .immediate,
        cameraAccessClient: accessClient,
        photoLibraryAccessClient: .noop,
        textRecognitionClient: .noop
      )
    )

    store.send(.takePhotosButtonTapped)
    store.receive(.requestCameraAccess)
    store.receive(.requestCameraAccessResult(true))
    store.receive(.setShowCamera(true)) {
      $0.showCamera = true
    }
    subject.send(completion: .finished)
  }
}
