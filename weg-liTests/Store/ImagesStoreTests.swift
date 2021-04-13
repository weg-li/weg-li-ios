// Created for weg-li in 2021.

import Combine
import ComposableArchitecture
import ComposableCoreLocation
@testable import weg_li
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
                imageConverter: .noop,
                photoLibraryAccessClient: .noop
            )
        )

        let pencilImage = StorableImage(uiImage: UIImage(systemName: "pencil")!)!
        let trashImage = StorableImage(uiImage: UIImage(systemName: "trash")!)!
        store.assert(
            .send(.addPhotos([pencilImage, trashImage])) {
                $0.storedPhotos = [
                    pencilImage,
                    trashImage,
                ]
            }
        )
    }

    func test_removePhoto_shouldUpdateState() {
        let image1 = UIImage(systemName: "pencil")!
        let id1 = UUID()
        let storableImage1 = StorableImage(id: id1, uiImage: image1)

        let image2 = UIImage(systemName: "pencil")!
        let id2 = UUID()
        let storableImage2 = StorableImage(id: id2, uiImage: image2)

        let store = TestStore(
            initialState: ImagesViewState(
                showImagePicker: false,
                storedPhotos: [storableImage1, storableImage2],
                coordinateFromImagePicker: .zero
            ),
            reducer: imagesReducer,
            environment: ImagesViewEnvironment(
                mainQueue: scheduler,
                imageConverter: .noop,
                photoLibraryAccessClient: .noop
            )
        )

        store.assert(
            .send(.image(id: id1, action: .removePhoto)) {
                $0.storedPhotos = [storableImage2]
            }
        )
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
                imageConverter: .noop,
                photoLibraryAccessClient: .noop
            )
        )

        let pencil = UIImage(systemName: "pencil")!
        let trash = UIImage(systemName: "trash")!

        let pencilImage = StorableImage(uiImage: pencil)!
        let trashImage = StorableImage(uiImage: trash)!

        store.assert(
            .send(.addPhotos([pencilImage, trashImage])) {
                $0.storedPhotos = [pencilImage, trashImage]
            },
            .send(.setResolvedCoordinate(.init(latitude: 23.32, longitude: 13.31))) {
                $0.coordinateFromImagePicker = .init(latitude: 23.32, longitude: 13.31)
            }
        )
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
                imageConverter: .noop,
                photoLibraryAccessClient: .noop
            )
        )

        let pencil = UIImage(systemName: "pencil")!
        let trash = UIImage(systemName: "trash")!

        let pencilImage = StorableImage(uiImage: pencil)!
        let trashImage = StorableImage(uiImage: trash)!

        store.assert(
            .send(.addPhotos([pencilImage, trashImage])) {
                $0.storedPhotos = [pencilImage, trashImage]
            },
            .send(.setResolvedCoordinate(.init(latitude: 23.32, longitude: 13.31))) {
                $0.coordinateFromImagePicker = .init(latitude: 23.32, longitude: 13.31)
            },
            .send(.setResolvedCoordinate(.init(latitude: 23.3200000001, longitude: 13.3100000001))) {
                $0.coordinateFromImagePicker = .init(latitude: 23.32, longitude: 13.31)
            }
        )
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
                imageConverter: .noop,
                photoLibraryAccessClient: accessClient
            )
        )

        store.assert(
            .send(.addPhotosButtonTapped),
            .receive(.requestPhotoLibraryAccess),
            .receive(.requestPhotoLibraryAccessResult(.authorized)),
            .receive(.setShowImagePicker(true)) {
                $0.showImagePicker = true
            },
            .do { subject.send(completion: .finished) }
        )
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
                imageConverter: .noop,
                photoLibraryAccessClient: accessClient
            )
        )

        store.assert(
            .send(.addPhotosButtonTapped),
            .receive(.requestPhotoLibraryAccess),
            .receive(.requestPhotoLibraryAccessResult(.limited)),
            .receive(.setShowImagePicker(true)) {
                $0.showImagePicker = true
            },
            .do { subject.send(completion: .finished) }
        )
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
                imageConverter: .noop,
                photoLibraryAccessClient: accessClient
            )
        )

        store.assert(
            .send(.addPhotosButtonTapped),
            .receive(.requestPhotoLibraryAccess),
            .receive(.requestPhotoLibraryAccessResult(.denied)) {
                $0.alert = .init(title: TextState(L10n.Photos.Alert.accessDenied))
            },
            .do { subject.send(completion: .finished) }
        )
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
                imageConverter: .noop,
                photoLibraryAccessClient: .noop
            )
        )

        store.assert(
            .send(.dismissAlert) {
                $0.alert = nil
            }
        )
    }
}
