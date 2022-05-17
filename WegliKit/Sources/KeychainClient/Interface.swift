import ComposableArchitecture
import Foundation
import KeychainSwift

public struct KeychainClient {
  public var getString: (String) -> Effect<String?, Never>
  public var setString: (String, String, KeychainSwiftAccessOptions?) -> Effect<Bool, Never>
  public var delete: (String) -> Effect<Bool, Never>
  public var clear: () -> Effect<Bool, Never>
  
  public init(
    getString: @escaping (String) -> Effect<String?, Never>,
    setString: @escaping (String, String, KeychainSwiftAccessOptions?) -> Effect<Bool, Never>,
    delete: @escaping (String) -> Effect<Bool, Never>,
    clear: @escaping () -> Effect<Bool, Never>
  ) {
    self.getString = getString
    self.setString = setString
    self.delete = delete
    self.clear = clear
  }
  
  public func setApiToken(_ token: String) -> Effect<Bool, Never> {
    setString(token, tokenKey, nil)
  }
  
  public func getApiToken() -> Effect<String?, Never> {
    getString(tokenKey)
  }
}

let tokenKey = "API-Token"
