import Combine
import Foundation
import KeychainClient

/// A Client to dispatch network calls
public struct APIClient {
  public var networkDispatcher: () -> NetworkDispatcher
  var tokenStore: () -> KeychainClient
  
  public init(
    networkDispatcher: @escaping () -> NetworkDispatcher,
    tokenStore: @escaping () -> KeychainClient
  ) {
    self.networkDispatcher = networkDispatcher
    self.tokenStore = tokenStore
  }
  
  func addToken(to request: inout URLRequest) {
    if let token = tokenStore().getToken() {
      request.addValue(token, forHTTPHeaderField: apiTokenKey)
    }
  }
  
  /// Dispatches a Request and returns a publisher
  /// - Parameter request: Request to Dispatch
  /// - Returns: A publisher containing decoded data or an error
  public func dispatch(_ request: Request) async throws -> Data {
    guard var urlRequest = try? request.makeRequest() else {
      throw NetworkRequestError.badRequest
    }
    addToken(to: &urlRequest)
    return try await networkDispatcher().dispatch(request: urlRequest)
  }
}

public extension APIClient {
  static let live = Self(networkDispatcher: { .live }, tokenStore: { .live() })
  static let noop = Self(networkDispatcher: { .noop }, tokenStore: { .noop })
}

private let apiTokenKey = "X-API-KEY"
