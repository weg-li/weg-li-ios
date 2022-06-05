import ComposableArchitecture
import UIKit.UIApplication

public extension UIApplicationClient {
  static let noop = Self(
    open: { _, _ in .none },
    openSettingsURLString: { "" }
  )
}
