import Foundation
import KeychainSwift

public extension KeychainClient {
  static let noop = Self(
    getString: { _ in .none },
    setString: { _, _, _ in .none },
    delete: { _ in .none },
    clear: { .none },
    getToken: { nil }
  )
}
