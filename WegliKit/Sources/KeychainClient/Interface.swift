import ComposableArchitecture
import Foundation
import KeychainSwift

public struct KeychainClient {
  public var getString: (String) -> Effect<String?, Never>
  public var setString: (String, String, KeychainSwiftAccessOptions?) -> Effect<Bool, Never>
  public var delete: (String) -> Effect<Bool, Never>
  public var clear: () -> Effect<Bool, Never>
  public var getToken: () -> String?

  public init(
    getString: @escaping (String) -> Effect<String?, Never>,
    setString: @escaping (String, String, KeychainSwiftAccessOptions?) -> Effect<Bool, Never>,
    delete: @escaping (String) -> Effect<Bool, Never>,
    clear: @escaping () -> Effect<Bool, Never>,
    getToken: @escaping () -> String?
  ) {
    self.getString = getString
    self.setString = setString
    self.delete = delete
    self.clear = clear
    self.getToken = getToken
  }
  
  public func setApiToken(_ token: String) -> Effect<Bool, Never> {
    setString(token, tokenKey, nil)
  }
  
  public func getApiToken() -> Effect<Result<String?, NSError>, Never> {
    getString(tokenKey)
      .setFailureType(to: NSError.self)
      .catchToEffect()
  }
}

let tokenKey = "API-Token"
