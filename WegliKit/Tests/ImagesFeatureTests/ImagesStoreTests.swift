// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import ComposableCoreLocation
import ImagesFeature
import L10n
import PhotoLibraryAccessClient
import SharedModels
import XCTest

@MainActor
final class ImagesStoreTests: XCTestCase {
  let clock = TestClock()
  
  func test_addPhoto_shouldUpdateState() async {
    let creationDate: Date = .init(timeIntervalSince1970: 0)
    let coordinate: CoordinateRegion.Coordinate = .init(latitude: 23.32, longitude: 13.31)
    
    let pencilImage = PickerImageResult(
      id: "pencil",
      imageUrl: .init(string: ""),
      coordinate: coordinate,
      creationDate: creationDate
    )
    let trashImage = PickerImageResult(
      id: "trash",
      imageUrl: .init(string: ""),
      coordinate: coordinate,
      creationDate: creationDate
    )
    let heartImage = PickerImageResult(
      id: "heart",
      imageUrl: .init(string: ""),
      coordinate: coordinate,
      creationDate: creationDate
    )
    
    var textItems = [
      TextItem(id: pencilImage.id, text: "HH.TV 3000"),
      TextItem(id: trashImage.id, text: "Trash"),
      TextItem(id: heartImage.id, text: "B-MB 1985"),
      TextItem(id: trashImage.id, text: "Trash"),
      TextItem(id: heartImage.id, text: "B-MB 1985")
    ]
    
    let store = TestStore(
      initialState: ImagesViewDomain.State(
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: ImagesViewDomain(),
      prepareDependencies: { values in
        values.continuousClock = ImmediateClock()
        values.cameraAccessClient = .mock
        values.photoLibraryAccessClient = .noop
        values.textRecognitionClient = .init(recognizeText: { _ in [textItems.removeFirst()] })
      }
    )
    
    await store.send(.setPhotos([pencilImage, trashImage, heartImage])) {
      $0.storedPhotos = [
        pencilImage,
        trashImage,
        heartImage
      ]
      $0.isRecognizingTexts = true
    }
    await store.receive(.setImageCoordinate(coordinate.asCLLocationCoordinate2D)) {
      $0.pickerResultCoordinate = coordinate.asCLLocationCoordinate2D
    }
    await store.receive(.setImageCreationDate(creationDate)) {
      $0.pickerResultDate = creationDate
    }
    await store.receive(.textRecognitionCompleted(.success([
      TextItem(id: pencilImage.id, text: "HH.TV 3000"),
      TextItem(id: trashImage.id, text: "Trash"),
      TextItem(id: heartImage.id, text: "B-MB 1985")
    ]))) {
      $0.isRecognizingTexts = false
      $0.licensePlates = [
        TextItem(id: pencilImage.id, text: "HH TV 3000"),
        TextItem(id: heartImage.id, text: "B MB 1985")
      ]
    }
    
    await store.send(.image(id: pencilImage.id, action: .onRemovePhotoButtonTapped)) {
      $0.licensePlates = [
        TextItem(id: heartImage.id, text: "B MB 1985")
      ]
      $0.storedPhotos = [
        trashImage,
        heartImage
      ]
    }
    await store.receive(.setImageCoordinate(coordinate.asCLLocationCoordinate2D))
    await store.receive(.setImageCreationDate(creationDate))
  }
  
  func test_removePhoto_shouldUpdateState() {
    let image1 = UIImage(systemName: "pencil")!
    let id1 = UUID().uuidString
    let storableImage1 = PickerImageResult(id: id1, uiImage: image1)
    
    let image2 = UIImage(systemName: "pencil")!
    let id2 = UUID().uuidString
    let storableImage2 = PickerImageResult(id: id2, uiImage: image2)
    
    let store = TestStore(
      initialState: ImagesViewDomain.State(
        showImagePicker: false,
        storedPhotos: [storableImage1, storableImage2],
        coordinateFromImagePicker: .zero
      ),
      reducer: ImagesViewDomain(),
      prepareDependencies: { values in
        values.continuousClock = ImmediateClock()
        values.cameraAccessClient = .mock
        values.photoLibraryAccessClient = .noop
        values.textRecognitionClient = .noop
      }
    )
    
    store.send(.image(id: id1, action: .onRemovePhotoButtonTapped)) {
      $0.storedPhotos = [storableImage2]
    }
  }
  
  func test_selectMultiplePhotos_shouldAddPhotosAndSetCoordinate() async throws {
    let store = TestStore(
      initialState: ImagesViewDomain.State(
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: ImagesViewDomain(),
      prepareDependencies: { values in
        values.continuousClock = ImmediateClock()
        values.cameraAccessClient = .mock
        values.photoLibraryAccessClient = .noop
        values.textRecognitionClient.recognizeText = { _ in [] }
      }
    )
      
    let creationDate: Date = .init(timeIntervalSince1970: 0)
    let coordinate: CoordinateRegion.Coordinate = .init(latitude: 23.32, longitude: 13.31)

    let pencilImage = PickerImageResult(
      id: "pencil",
      imageUrl: .init(string: ""),
      coordinate: coordinate,
      creationDate: creationDate
    )
    let trashImage = PickerImageResult(
      id: "trash",
      imageUrl: .init(string: ""),
      coordinate: .init(latitude: 36.32, longitude: 0.31),
      creationDate: creationDate
    )
    
    await store.send(.setPhotos([pencilImage, trashImage])) {
      $0.isRecognizingTexts = true
      $0.storedPhotos = [pencilImage, trashImage]
    }
    await store.receive(.setImageCoordinate(coordinate.asCLLocationCoordinate2D)) {
      $0.pickerResultCoordinate = coordinate.asCLLocationCoordinate2D
    }
    await store.receive(.setImageCreationDate(creationDate)) {
      $0.pickerResultDate = creationDate
    }
    await store.receive(.textRecognitionCompleted(.success([]))) {
      $0.isRecognizingTexts = false
    }
  }
  
  func test_selectMultiplePhotos_withSmallCoordinateUpdateShouldOnlySetCoordinateOnce() async {
    let store = TestStore(
      initialState: ImagesViewDomain.State(
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: ImagesViewDomain(),
      prepareDependencies: { values in
        values.continuousClock = clock
        values.cameraAccessClient = .mock
        values.photoLibraryAccessClient = .noop
        values.textRecognitionClient = .noop
      }
    )
    
    let creationDate: Date = .init(timeIntervalSince1970: 0)
    let coordinate: CoordinateRegion.Coordinate = .init(latitude: 23.32, longitude: 13.31)
    
    let pencilImage = PickerImageResult(
      id: "pencil",
      imageUrl: .init(string: ""),
      coordinate: coordinate,
      creationDate: creationDate
    )
    let trashImage = PickerImageResult(
      id: "trash",
      imageUrl: .init(string: ""),
      coordinate: .init(latitude: 36.32, longitude: 0.31),
      creationDate: creationDate
    )
    
    await store.send(.setPhotos([pencilImage, trashImage])) {
      $0.isRecognizingTexts = true
      $0.storedPhotos = [pencilImage, trashImage]
    }
    await store.receive(.setImageCoordinate(coordinate.asCLLocationCoordinate2D)) {
      $0.pickerResultCoordinate = coordinate.asCLLocationCoordinate2D
    }
    await store.receive(.setImageCreationDate(creationDate)) {
      $0.pickerResultDate = creationDate
    }
    await store.receive(.textRecognitionCompleted(.success([]))) {
      $0.isRecognizingTexts = false
    }
  }
  
  func test_addPhotosButtonTapped_shouldRequestAccess_andPresentPicker_whenAuthorised() async {
    let accessClient = PhotoLibraryAccessClient(
      requestAuthorization: { .authorized },
      authorizationStatus: { .notDetermined }
    )
    
    let store = TestStore(
      initialState: ImagesViewDomain.State(
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: ImagesViewDomain(),
      prepareDependencies: { values in
        values.continuousClock = clock
        values.cameraAccessClient = .mock
        values.photoLibraryAccessClient = accessClient
        values.textRecognitionClient = .noop
      }
    )
    
    await store.send(.onAddPhotosButtonTapped)
    await store.receive(.requestPhotoLibraryAccess)
    await store.receive(.requestPhotoLibraryAccessResult(.authorized))
    await store.receive(.setShowImagePicker(true)) {
      $0.showImagePicker = true
    }
  }
  
  func test_addPhotosButtonTapped_shouldRequestAccess_andPresentPicker_whenLimited() async {
    let accessClient = PhotoLibraryAccessClient(
      requestAuthorization: { .limited },
      authorizationStatus: { .notDetermined }
    )
    
    let store = TestStore(
      initialState: ImagesViewDomain.State(
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: ImagesViewDomain(),
      prepareDependencies: { values in
        values.continuousClock = clock
        values.cameraAccessClient = .mock
        values.photoLibraryAccessClient = accessClient
        values.textRecognitionClient = .noop
      }
    )
    
    await store.send(.onAddPhotosButtonTapped)
    await store.receive(.requestPhotoLibraryAccess)
    await store.receive(.requestPhotoLibraryAccessResult(.limited))
    await store.receive(.setShowImagePicker(true)) {
      $0.showImagePicker = true
    }
  }
  
  func test_addPhotosButtonTapped_shouldRequestAccess_andPresentAlert_whenAccessIsDenied() async {
    let accessClient = PhotoLibraryAccessClient(
      requestAuthorization: { .denied },
      authorizationStatus: { .notDetermined }
    )
    
    let store = TestStore(
      initialState: ImagesViewDomain.State(
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: ImagesViewDomain(),
      prepareDependencies: { values in
        values.continuousClock = clock
        values.cameraAccessClient = .mock
        values.photoLibraryAccessClient = accessClient
        values.textRecognitionClient = .noop
      }
    )
    
    await store.send(.onAddPhotosButtonTapped)
    await store.receive(.requestPhotoLibraryAccess)
    await store.receive(.requestPhotoLibraryAccessResult(.denied)) {
      $0.alert = .init(title: TextState(L10n.Photos.Alert.accessDenied))
    }
  }
  
  func test_dismissAlert_shouldUpdateState() {
    let store = TestStore(
      initialState: ImagesViewDomain.State(
        alert: AlertState(title: TextState(L10n.Photos.Alert.accessDenied)),
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: ImagesViewDomain(),
      prepareDependencies: { values in
        values.continuousClock = clock
        values.cameraAccessClient = .mock
        values.photoLibraryAccessClient = .noop
        values.textRecognitionClient = .noop
      }
    )
    
    store.send(.dismissAlert) {
      $0.alert = nil
    }
  }
  
  func test_addPhotosButtonTapped_() async {
    let accessClient = PhotoLibraryAccessClient(
      requestAuthorization: { .denied },
      authorizationStatus: { .notDetermined }
    )
    
    let store = TestStore(
      initialState: ImagesViewDomain.State(
        showImagePicker: false,
        storedPhotos: [],
        coordinateFromImagePicker: .zero
      ),
      reducer: ImagesViewDomain(),
      prepareDependencies: { values in
        values.continuousClock = clock
        values.cameraAccessClient = .mock
        values.photoLibraryAccessClient = accessClient
        values.textRecognitionClient = .noop
      }
    )
    
    await store.send(.onAddPhotosButtonTapped)
    await store.receive(.requestPhotoLibraryAccess)
    await store.receive(.requestPhotoLibraryAccessResult(.denied)) {
      $0.alert = .init(title: TextState(L10n.Photos.Alert.accessDenied))
    }
  }
}
