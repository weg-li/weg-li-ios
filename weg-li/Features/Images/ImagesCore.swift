// Created for weg-li in 2021.

import ComposableArchitecture
import CoreLocation
import Foundation
import UIKit

struct ImagesViewState: Equatable, Codable {
    var showImagePicker: Bool = false
    var storedPhotos: [StorableImage?] = []
    var coordinateFromImagePicker: CLLocationCoordinate2D?

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
    case setShowImagePicker(Bool)
    case setResolvedCoordinate(CLLocationCoordinate2D?)
    case image(id: UUID, action: ImageAction)
}

struct ImagesViewEnvironment {
    let imageConverter: ImageConverter
    let distanceFilter: Double = 50
}

/// Reducer handling actions from ImagesView combined with the single Image reducer.
let imagesReducer = Reducer<ImagesViewState, ImagesViewAction, ImagesViewEnvironment> { state, action, env in
    switch action {
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
    case let .setShowImagePicker(value):
        state.showImagePicker = value
        return .none
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
    }
}
