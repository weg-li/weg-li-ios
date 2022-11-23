import Dependencies
import UIKit.UIApplication

extension UIApplicationClient: DependencyKey {
  public static var liveValue: UIApplicationClient = live
  
  static let live = Self(
    open: { @MainActor in await UIApplication.shared.open($0, options: $1) },
    openSettingsURLString: { await UIApplication.openSettingsURLString }
  )
}
