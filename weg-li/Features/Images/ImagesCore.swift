// Created for weg-li in 2021.

import ComposableArchitecture
import CoreLocation
import Foundation
import UIKit

struct ImagesViewState: Equatable, Codable {
    var alert: AlertState<ImagesViewAction>?
    var showImagePicker: Bool = false
    var storedPhotos: [StorableImage?] = []
    var coordinateFromImagePicker: CLLocationCoordinate2D?

    private enum CodingKeys: String, CodingKey {
        case storedPhotos
        case coordinateFromImagePicker
    }

    var imageStates: IdentifiedArrayOf<ImageState> {
        IdentifiedArray(
            storedPhotos
                .compactMap { $0 }
                .map { ImageState(id: $0.id, image: $0) }
        )
    }
}

enum ImagesViewAction: Equatable {
    case addPhotos([StorableImage?])
    case addPhotosButtonTapped
    case setShowImagePicker(Bool)
    case requestPhotoLibraryAccess
    case requestPhotoLibraryAccessResult(PhotoLibraryAuthorizationStatus)
    case setResolvedCoordinate(CLLocationCoordinate2D?)
    case dismissAlert
    case image(id: UUID, action: ImageAction)
}

struct ImagesViewEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    let imageConverter: ImageConverter
    let distanceFilter: Double = 50
    let photoLibraryAccessClient: PhotoLibraryAccessClient
}

/// Reducer handling actions from ImagesView combined with the single Image reducer.
let imagesReducer = Reducer<ImagesViewState, ImagesViewAction, ImagesViewEnvironment> { state, action, env in
    switch action {
    case .addPhotosButtonTapped:
        switch env.photoLibraryAccessClient.authorizationStatus() {
        case .notDetermined:
            return Effect(value: .requestPhotoLibraryAccess)
        case .restricted, .denied:
            state.alert = .init(title: TextState(L10n.Photos.Alert.accessDenied))
            return .none
        case .authorized, .limited:
            return Effect(value: .setShowImagePicker(true))
        @unknown default:
            return .none
        }

    case let .setShowImagePicker(value):
        state.showImagePicker = value
        return .none

    case .requestPhotoLibraryAccess:
        return env.photoLibraryAccessClient
            .requestAuthorization()
            .receive(on: env.mainQueue)
            .map(ImagesViewAction.requestPhotoLibraryAccessResult)
            .eraseToEffect()
    case let .requestPhotoLibraryAccessResult(status):
        switch status {
        case .authorized, .limited:
            return Effect(value: .setShowImagePicker(true))
        case .notDetermined:
            // show alert
            return .none
        case .denied:
            state.alert = .init(title: TextState(L10n.Photos.Alert.accessDenied))
            return .none
        default:
            return .none
        }
    case let .addPhotos(photos):
        state.storedPhotos = photos
        return .none
    // set photo coordinate from selected photos first element.
    case let .setResolvedCoordinate(coordinate):
        guard let coordinate = coordinate, let resolvedCoordinate = state.coordinateFromImagePicker else {
            return .none
        }
        let resolved = CLLocation(from: resolvedCoordinate)
        let location = CLLocation(from: coordinate)

        if resolved.distance(from: location) < env.distanceFilter {
            return .none
        }

        state.coordinateFromImagePicker = coordinate
        return .none
    case let .image(id, imageAction):
        switch imageAction {
        // filter storedPhotos by image ID which removes the selected one.
        case .removePhoto:
            let photos = state.storedPhotos
                .compactMap { $0 }
                .filter { $0.id != id }
            state.storedPhotos = photos
            return .none
        }
    case .dismissAlert:
        state.alert = nil
        return .none
    }
}
