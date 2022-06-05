import ComposableArchitecture
import UIKit.UIApplication

public struct UIApplicationClient {
  public init(
    open: @escaping (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) -> Effect<Bool, Never>,
    openSettingsURLString: @escaping () -> String
  ) {
    self.open = open
    self.openSettingsURLString = openSettingsURLString
  }
  
  public var open: (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) -> Effect<Bool, Never>
  public var openSettingsURLString: () -> String
}
