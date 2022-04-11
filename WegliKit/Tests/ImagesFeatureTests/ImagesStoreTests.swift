// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import ImagesFeature
import L10n
import PhotoLibraryAccessClient
import SharedModels
import XCTest

class ImagesStoreTests: XCTestCase {
  let scheduler = DispatchQueue.immediate.eraseToAnyScheduler()
  
  func test_addPhoto_shouldUpdateState() {
    let store = TestStore(
      initialState: ImagesViewState(
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: imagesReducer,
      environment: ImagesViewEnvironment(
        mainQueue: scheduler,
        photoLibraryAccessClient: .noop
      )
    )
    
    let pencilImage = StorableImage(uiImage: UIImage(systemName: "pencil")!)!
    let trashImage = StorableImage(uiImage: UIImage(systemName: "trash")!)!
    store.send(.setPhotos([pencilImage, trashImage])) {
      $0.storedPhotos = [
        pencilImage,
        trashImage,
      ]
    }
  }
  
  func test_removePhoto_shouldUpdateState() {
    let image1 = UIImage(systemName: "pencil")!
    let id1 = UUID().uuidString
    let storableImage1 = StorableImage(id: id1, uiImage: image1)
    
    let image2 = UIImage(systemName: "pencil")!
    let id2 = UUID().uuidString
    let storableImage2 = StorableImage(id: id2, uiImage: image2)
    
    let store = TestStore(
      initialState: ImagesViewState(
        showImagePicker: false,
        storedPhotos: [storableImage1, storableImage2],
        coordinateFromImagePicker: .zero
      ),
      reducer: imagesReducer,
      environment: ImagesViewEnvironment(
        mainQueue: .immediate,
        photoLibraryAccessClient: .noop
      )
    )
    
    store.send(.image(id: id1, action: .removePhoto))
    store.receive(.setPhotos([storableImage2])) {
      $0.storedPhotos = [storableImage2]
    }
  }
  
  func test_selectMultiplePhotos_shouldAddPhotosAndSetCoordinate() {
    let store = TestStore(
      initialState: ImagesViewState(
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: imagesReducer,
      environment: ImagesViewEnvironment(
        mainQueue: scheduler,
        photoLibraryAccessClient: .noop
      )
    )
    
    let pencil = UIImage(systemName: "pencil")!
    let trash = UIImage(systemName: "trash")!
    
    let pencilImage = StorableImage(uiImage: pencil)!
    let trashImage = StorableImage(uiImage: trash)!
    
    store.send(.setPhotos([pencilImage, trashImage])) {
      $0.storedPhotos = [pencilImage, trashImage]
    }
    store.send(.setResolvedCoordinate(.init(latitude: 23.32, longitude: 13.31))) {
      $0.coordinateFromImagePicker = .init(latitude: 23.32, longitude: 13.31)
    }
  }
  
  func test_selectMultiplePhotos_withSmallCoordinateUpdateShouldOnlySetCoordinateOnce() {
    let store = TestStore(
      initialState: ImagesViewState(
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: imagesReducer,
      environment: ImagesViewEnvironment(
        mainQueue: scheduler,
        photoLibraryAccessClient: .noop
      )
    )
    
    let pencil = UIImage(systemName: "pencil")!
    let trash = UIImage(systemName: "trash")!
    
    let pencilImage = StorableImage(uiImage: pencil)!
    let trashImage = StorableImage(uiImage: trash)!
    
    store.send(.setPhotos([pencilImage, trashImage])) {
      $0.storedPhotos = [pencilImage, trashImage]
    }
    store.send(.setResolvedCoordinate(.init(latitude: 23.32, longitude: 13.31))) {
      $0.coordinateFromImagePicker = .init(latitude: 23.32, longitude: 13.31)
    }
    store.send(.setResolvedCoordinate(.init(latitude: 23.3200000001, longitude: 13.3100000001))) {
      $0.coordinateFromImagePicker = .init(latitude: 23.32, longitude: 13.31)
    }
  }
  
  func test_addPhotosButtonTapped_shouldRequestAccess_andPresentPicker_whenAuthorised() {
    let subject = CurrentValueSubject<PhotoLibraryAuthorizationStatus, Never>(.authorized)
    let accessClient = PhotoLibraryAccessClient(
      requestAuthorization: {
        Effect(subject)
      },
      authorizationStatus: { .notDetermined }
    )
    
    let store = TestStore(
      initialState: ImagesViewState(
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: imagesReducer,
      environment: ImagesViewEnvironment(
        mainQueue: scheduler,
        photoLibraryAccessClient: accessClient
      )
    )
    
    store.send(.addPhotosButtonTapped)
    store.receive(.requestPhotoLibraryAccess)
    store.receive(.requestPhotoLibraryAccessResult(.authorized))
    store.receive(.setShowImagePicker(true)) {
      $0.showImagePicker = true
    }
    subject.send(completion: .finished)
  }
  
  func test_addPhotosButtonTapped_shouldRequestAccess_andPresentPicker_whenLimited() {
    let subject = CurrentValueSubject<PhotoLibraryAuthorizationStatus, Never>(.limited)
    let accessClient = PhotoLibraryAccessClient(
      requestAuthorization: {
        Effect(subject)
      },
      authorizationStatus: { .notDetermined }
    )
    
    let store = TestStore(
      initialState: ImagesViewState(
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: imagesReducer,
      environment: ImagesViewEnvironment(
        mainQueue: scheduler,
        photoLibraryAccessClient: accessClient
      )
    )
    
    store.send(.addPhotosButtonTapped)
    store.receive(.requestPhotoLibraryAccess)
    store.receive(.requestPhotoLibraryAccessResult(.limited))
    store.receive(.setShowImagePicker(true)) {
      $0.showImagePicker = true
    }
    subject.send(completion: .finished)
  }
  
  func test_addPhotosButtonTapped_shouldRequestAccess_andPresentAlert_whenAccessIsDenied() {
    let subject = CurrentValueSubject<PhotoLibraryAuthorizationStatus, Never>(.denied)
    let accessClient = PhotoLibraryAccessClient(
      requestAuthorization: {
        Effect(subject)
      },
      authorizationStatus: { .notDetermined }
    )
    
    let store = TestStore(
      initialState: ImagesViewState(
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: imagesReducer,
      environment: ImagesViewEnvironment(
        mainQueue: scheduler,
        photoLibraryAccessClient: accessClient
      )
    )
    
    store.send(.addPhotosButtonTapped)
    store.receive(.requestPhotoLibraryAccess)
    store.receive(.requestPhotoLibraryAccessResult(.denied)) {
      $0.alert = .init(title: TextState(L10n.Photos.Alert.accessDenied))
    }
    subject.send(completion: .finished)
  }
  
  func test_dismissAlert_shouldUpdateState() {
    let store = TestStore(
      initialState: ImagesViewState(
        alert: AlertState(title: TextState(L10n.Photos.Alert.accessDenied)),
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: imagesReducer,
      environment: ImagesViewEnvironment(
        mainQueue: scheduler,
        photoLibraryAccessClient: .noop
      )
    )
    
    store.send(.dismissAlert) {
      $0.alert = nil
    }
  }
}
