// Created for weg-li in 2021.

import ComposableArchitecture
import CoreLocation
import Foundation
import UIKit

struct ImagesViewState: Equatable, Codable {
    var showImagePicker: Bool = false
    var storedPhotos: [StorableImage?] = []
    var resolvedLocation: CLLocationCoordinate2D = .zero

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
    case setResolvedCoordinate(CLLocationCoordinate2D)
    case image(id: UUID, action: ImageAction)
}

struct ImagesViewEnvironment {
    let imageConverter: ImageConverter
    let distanceFilter: Double = 50
}

let imagesReducer = Reducer<ImagesViewState, ImagesViewAction, ImagesViewEnvironment> { state, action, env in
    switch action {
    case let .image(id, imageAction):
        switch imageAction {
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
    case let .setResolvedCoordinate(coordinate):
        let resolved = CLLocation(from: state.resolvedLocation)
        let location = CLLocation(from: coordinate)

        if resolved.distance(from: location) < env.distanceFilter {
            return .none
        }

        state.resolvedLocation = coordinate
        return .none
    }
}
