import Dependencies
import Foundation
import KeychainSwift
import XCTestDynamicOverlay

extension KeychainClient: TestDependencyKey {
  static let noop = Self(
    getString: { _ in nil },
    setString: { _, _, _ in false },
    delete: { _ in false },
    clear: { false },
    getToken: { nil }
  )
  
  public static let testValue: KeychainClient = Self(
    getString: unimplemented("\(Self.self).getString", placeholder: nil),
    setString: unimplemented("\(Self.self).setString", placeholder: false),
    delete: unimplemented("\(Self.self).delete", placeholder: false),
    clear: unimplemented("\(Self.self).clear", placeholder: false),
    getToken: unimplemented("\(Self.self).getToken", placeholder: nil)
  )
}
