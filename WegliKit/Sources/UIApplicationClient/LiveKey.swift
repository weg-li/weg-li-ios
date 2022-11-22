import UIKit.UIApplication

public extension UIApplicationClient {
  static let live = Self(
    open: { @MainActor in await UIApplication.shared.open($0, options: $1) },
    openSettingsURLString: { await UIApplication.openSettingsURLString }
  )
}
