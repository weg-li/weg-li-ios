import ComposableArchitecture
import FileClient
import Foundation
import ReportFeature
import SharedModels

public struct AppDelegateDomain: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {}
  
  public enum Action: Equatable {
    case didFinishLaunching
  }
  
  public func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .didFinishLaunching:
      return .none
    }
  }
}
