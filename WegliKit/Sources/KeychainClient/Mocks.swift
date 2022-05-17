import Foundation
import KeychainSwift

public extension KeychainClient {
  static let noop = Self(
    getString: { _ in return .none },
    setString: { _, _, _ in return .none },
    delete: { _ in return .none },
    clear: { return .none }
  )
}
