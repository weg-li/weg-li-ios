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
                resolvedLocation: nil),
            reducer: imagesReducer,
            environment: ImagesViewEnvironment(
                imageConverter: ImageConverterImplementation()
            ))

        let image = UIImage(systemName: "pencil")!
        store.assert(
            .send(.addPhoto(image)) {
                $0.storedPhotos = [
                    StorableImage(uiImage: image)!
                ]
            }
        )
    }

    func test_removePhoto_shouldUpdateState() {
        let image = UIImage(systemName: "pencil")!
        let store = TestStore(
            initialState: ImagesViewState(
                showImagePicker: false,
                storedPhotos: [StorableImage(uiImage: image)!],
                resolvedLocation: nil),
            reducer: imagesReducer,
            environment: ImagesViewEnvironment(
                imageConverter: ImageConverterImplementation()
            ))

        store.assert(
            .send(.removePhoto(index: 0)) {
                $0.storedPhotos = []
            }
        )
    }
}
