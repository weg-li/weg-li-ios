//
//  ImageCore.swift
//  weg-li
//
//  Created by Malte on 07.04.21.
//  Copyright © 2021 Martin Wilhelmi. All rights reserved.
//

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

let imageReducer = Reducer<ImageState, ImageAction, ImageEnvironment> { state, action, _ in
    switch action {
    case .removePhoto:
        return .none
    }
}
