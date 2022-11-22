import Dependencies
import UIKit.UIApplication
import XCTestDynamicOverlay

extension UIApplicationClient: TestDependencyKey {
  public static var previewValue: UIApplicationClient = Self.noop
  
  public static let testValue: UIApplicationClient = Self(
    open: unimplemented("\(Self.self).open", placeholder: false),
    openSettingsURLString: unimplemented("\(Self.self).openSettingsURLString")
  )
  
  static let noop = Self(
    open: { _, _ in false },
    openSettingsURLString: { "" }
  )
}
