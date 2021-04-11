// Created for weg-li in 2021.

import ComposableArchitecture
import ComposableCoreLocation
@testable import weg_li
import XCTest

class ImagesStoreTests: XCTestCase {
    func test_addPhoto_shouldUpdateState() {
        let store = TestStore(
            initialState: ImagesViewState(
                showImagePicker: false,
                storedPhotos: [],
                resolvedLocation: .zero
            ),
            reducer: imagesReducer,
            environment: ImagesViewEnvironment(
                imageConverter: ImageConverterImplementation()
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
                resolvedLocation: .zero
            ),
            reducer: imagesReducer,
            environment: ImagesViewEnvironment(
                imageConverter: ImageConverterImplementation()
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
                resolvedLocation: .zero
            ),
            reducer: imagesReducer,
            environment: ImagesViewEnvironment(
                imageConverter: ImageConverterImplementation()
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
                imageConverter: ImageConverterImplementation()
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
}
