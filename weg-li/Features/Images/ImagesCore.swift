//
//  ImagesCore.swift
//  weg-li
//
//  Created by Malte on 29.03.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

import ComposableArchitecture
import CoreLocation
import Foundation
import UIKit

struct ImagesViewState: Equatable, Codable {
    var showImagePicker: Bool = false
    var storedPhotos: [StorableImage] = []
    var resolvedLocation: CLLocationCoordinate2D?
}

enum ImagesViewAction: Equatable {
    case addPhoto(UIImage)
    case removePhoto(index: Int)
    case setShowImagePicker(Bool)
    case setResolvedCoordinate(CLLocationCoordinate2D?)
}

struct ImagesViewEnvironment {
    let imageConverter: ImageConverter
}

let imagesReducer = Reducer<ImagesViewState, ImagesViewAction, ImagesViewEnvironment> { state, action, environment in
    switch action {
    case let .setShowImagePicker(value):
        state.showImagePicker = value
        return .none
    case let .addPhoto(photo):
        let scaledImage = environment.imageConverter.scalePreservingAspectRatio(
            image: photo,
            targetSize: .init(width: 1000, height: 1000)
        )
        state.storedPhotos.append(StorableImage(uiImage: scaledImage)!)
        return .none
    case let .removePhoto(index):
        state.storedPhotos.remove(at: index)
        return .none
    case let .setResolvedCoordinate(coordinate):
        state.resolvedLocation = coordinate
        return .none
    }
}
