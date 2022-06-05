import ComposableArchitecture
import UIKit.UIApplication

public extension UIApplicationClient {
  static let live = Self(
    open: { url, options in
      .future { callback in
        UIApplication.shared.open(url, options: options) { bool in
          callback(.success(bool))
        }
      }
    },
    openSettingsURLString: { UIApplication.openSettingsURLString }
  )
}
