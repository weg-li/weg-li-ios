import Combine
import Dependencies
import Foundation
import KeychainSwift

extension KeychainClient: DependencyKey {
  public static var liveValue: KeychainClient { .live() }
  
  static func live(synchronizable: Bool = false) -> Self {
    let keychain = KeychainSwift(keyPrefix: "weg-li")
    keychain.synchronizable = synchronizable
    
    return Self(
      getString: { key in
        keychain.get(key)
      },
      setString: { value, key, options in
        keychain.set(value, forKey: key, withAccess: options)
      },
      delete: { key in
        keychain.delete(key)
      },
      clear: {
        keychain.clear()
      },
      getToken: { keychain.get(tokenKey) }
    )
  }
}
