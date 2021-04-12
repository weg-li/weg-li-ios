// Created for weg-li in 2021.

import ComposableArchitecture
import Foundation

struct ImageState: Equatable, Identifiable {
    let id: UUID
    let image: StorableImage

    internal init(id: UUID = UUID(), image: StorableImage) {
        self.id = id
        self.image = image
    }
}

enum ImageAction: Equatable {
    case removePhoto
}

struct ImageEnvironment {}

/// Reducer handling actions from a single ImageView.
let imageReducer = Reducer<ImageState, ImageAction, ImageEnvironment> { _, action, _ in
    switch action {
    case .removePhoto:
        return .none
    }
}
