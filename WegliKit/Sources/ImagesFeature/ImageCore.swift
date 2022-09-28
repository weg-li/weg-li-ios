// Created for weg-li in 2021.

import ComposableArchitecture
import Foundation
import SharedModels

public struct ImageState: Hashable, Identifiable {
  public init(id: String = UUID().uuidString, image: PickerImageResult) {
    self.id = id
    self.image = image
  }

  public let id: String
  public let image: PickerImageResult
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

public enum ImageAction: Equatable {
  case onRemovePhotoButtonTapped
  case onRecognizeTextButtonTapped
}

public struct ImageEnvironment {}

/// Reducer handling actions from a single ImageView.
public let imageReducer = Reducer<ImageState, ImageAction, ImageEnvironment> { _, action, _ in
  switch action {
  case .onRemovePhotoButtonTapped:
    return .none
    
  case .onRecognizeTextButtonTapped:
    return .none
  }
}
