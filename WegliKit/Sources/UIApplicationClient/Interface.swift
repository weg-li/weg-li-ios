import UIKit.UIApplication

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
