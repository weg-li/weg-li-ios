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
  
  /// Dispatches a Request and returns a publisher
  /// - Parameter request: Request to Dispatch
  /// - Returns: A publisher containing decoded data or an error
  public func send(_ request: Request) async throws -> Data {
    guard var urlRequest = try? request.makeRequest() else {
      throw NetworkRequestError.badRequest
    }
    guard let token = tokenStore().getToken(), !token.isEmpty else {
      throw ApiError.tokenUnavailable
    }
    urlRequest.addValue(token, forHTTPHeaderField: apiTokenKey)
    return try await networkDispatcher().dispatch(request: urlRequest)
  }
}

extension APIClient {
  static let live = Self(networkDispatcher: { .live }, tokenStore: { .liveValue })
  static let noop = Self(networkDispatcher: { .noop }, tokenStore: { .noop })
}

private let apiTokenKey = "X-API-KEY"
