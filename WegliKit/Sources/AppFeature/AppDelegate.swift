import ComposableArchitecture
import FileClient
import Foundation
import ReportFeature
import SharedModels

public struct AppDelegateState: Equatable {}

public enum AppDelegateAction: Equatable {
  case didFinishLaunching
}

public struct AppDelegateEnvironment {
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var fileClient: FileClient

  public init(
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    fileClient: FileClient
  ) {
    self.backgroundQueue = backgroundQueue
    self.mainQueue = mainQueue
    self.fileClient = fileClient
  }
}

let appDelegateReducer = Reducer<
  AppDelegateState, AppDelegateAction, AppDelegateEnvironment
> { _, action, _ in
  switch action {
  case .didFinishLaunching:
    return .none
  }
}
