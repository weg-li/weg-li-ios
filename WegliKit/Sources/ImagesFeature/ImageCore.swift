// Created for weg-li in 2021.

import ComposableArchitecture
import Foundation
import SharedModels

public struct ImageDomain: Reducer {
  public init() {}
  
  public struct State: Hashable, Identifiable {
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
  
  public enum Action: Equatable {
    case onRemovePhotoButtonTapped
    case onRecognizeTextButtonTapped
  }
  
  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .onRemovePhotoButtonTapped:
      return .none
      
    case .onRecognizeTextButtonTapped:
      return .none
    }
  }
}
