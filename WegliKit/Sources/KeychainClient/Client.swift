import Dependencies
import Foundation
import KeychainSwift

extension DependencyValues {
  public var keychainClient: KeychainClient {
    get { self[KeychainClient.self] }
    set { self[KeychainClient.self] = newValue }
  }
}

public struct KeychainClient {
  public var getString: @Sendable (String) async -> String?
  public var setString: @Sendable (String, String, KeychainSwiftAccessOptions?) async -> Bool
  public var delete: @Sendable (String) async -> Bool
  public var clear: @Sendable () async -> Bool
  public var getToken: () -> String?

  public init(
    getString: @Sendable @escaping (String) async -> String?,
    setString: @Sendable @escaping (String, String, KeychainSwiftAccessOptions?) async -> Bool,
    delete: @Sendable @escaping (String) async -> Bool,
    clear: @Sendable @escaping () async -> Bool,
    getToken: @Sendable @escaping () -> String?
  ) {
    self.getString = getString
    self.setString = setString
    self.delete = delete
    self.clear = clear
    self.getToken = getToken
  }
  
  public func setApiToken(_ token: String) async -> Bool {
    await setString(token, tokenKey, nil)
  }
  
  public func getApiToken() async -> String? {
    await getString(tokenKey)
  }
}

let tokenKey = "API-Token"
