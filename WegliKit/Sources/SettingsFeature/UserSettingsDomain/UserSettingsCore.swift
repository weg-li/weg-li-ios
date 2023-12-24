import ComposableArchitecture
import Foundation
import SharedModels

public struct UserSettingsDomain: Reducer {
  public init() {}
  
  public typealias State = UserSettings
 
  public enum Action: Equatable {
    case setShowsAllTextRecognitionResults(Bool)
    case onAlwaysSendNotice(Bool)
  }
  
  public func reduce(into state: inout UserSettings, action: Action) -> Effect<Action> {
    switch action {
    case .setShowsAllTextRecognitionResults(let value):
      state.showsAllTextRecognitionSettings = value
      return .none
      
    case .onAlwaysSendNotice(let value):
      state.alwaysSendNotice = value
      return .none
    }
  }
}
