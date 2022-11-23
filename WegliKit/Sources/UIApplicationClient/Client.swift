import Dependencies
import UIKit.UIApplication

extension DependencyValues {
  public var applicationClient: UIApplicationClient {
    get { self[UIApplicationClient.self] }
    set { self[UIApplicationClient.self] = newValue }
  }
}

public struct UIApplicationClient {
  public var open: @Sendable (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool
  public var openSettingsURLString: @Sendable () async -> String
  
  public init(
    open: @escaping @Sendable (URL, [UIApplication.OpenExternalURLOptionsKey : Any]) async -> Bool,
    openSettingsURLString: @escaping @Sendable () async -> String
  ) {
    self.open = open
    self.openSettingsURLString = openSettingsURLString
  }
}
