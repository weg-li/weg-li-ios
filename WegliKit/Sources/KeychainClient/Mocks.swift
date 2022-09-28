import Foundation
import KeychainSwift

public extension KeychainClient {
  static let noop = Self(
    getString: { _ in nil },
    setString: { _, _, _ in false },
    delete: { _ in false },
    clear: { false },
    getToken: { nil }
  )
}
