import ComposableArchitecture
import Foundation
import SharedModels

public struct UserSettingsDomain: ReducerProtocol {
  public init() {}
  
  public typealias State = UserSettings
 
  public enum Action: Equatable {
    case setShowsAllTextRecognitionResults(Bool)
  }
  
  public func reduce(into state: inout UserSettings, action: Action) -> EffectTask<Action> {
    switch action {
    case let .setShowsAllTextRecognitionResults(value):
      state.showsAllTextRecognitionSettings = value
      return .none
    }
  }
}
