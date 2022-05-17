import Combine
import ComposableArchitecture
import Foundation
import KeychainSwift

public extension KeychainClient {
  static func live(synchronizable: Bool = false) -> Self {
    let keychain = KeychainSwift(keyPrefix: "weg-li")
    keychain.synchronizable = synchronizable
    
    return Self(
      getString: { key in
        Effect(Just(keychain.get(key)))
      },
      setString: { value, key, options in
        Effect(Just(keychain.set(value, forKey: key, withAccess: options)))
      },
      delete: { key in
        Effect(Just(keychain.delete(key)))
      },
      clear: {
        Effect(Just(keychain.clear()))
      }
    )
  }
}
