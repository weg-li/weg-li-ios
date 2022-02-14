// Created for weg-li in 2021.

import ComposableArchitecture
import Foundation
import SharedModels

public struct ImageState: Equatable, Identifiable {
  public init(id: String = UUID().uuidString, image: StorableImage) {
    self.id = id
    self.image = image
  }
  public let id: String
  public let image: StorableImage
}

public enum ImageAction: Equatable {
  case removePhoto
}

public struct ImageEnvironment {}

/// Reducer handling actions from a single ImageView.
public let imageReducer = Reducer<ImageState, ImageAction, ImageEnvironment> { _, action, _ in
  switch action {
  case .removePhoto:
    return .none
  }
}
